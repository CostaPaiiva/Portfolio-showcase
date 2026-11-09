import { mkdir, rm, writeFile, readFile, readdir, stat } from 'node:fs/promises';
import { existsSync } from 'node:fs';

export async function fileAction(
  operation: 'create_folder' | 'delete_folder' | 'write_file' | 'delete_file' | 'read_file' | 'list_directory',
  payloadStr: string
): Promise<string> {
  let targetPath = '';
  let content = '';

  try {
    const parsed = JSON.parse(payloadStr);
    targetPath = parsed.path;
    content = parsed.content ?? '';
  } catch {
    targetPath = payloadStr;
  }

  if (!targetPath || typeof targetPath !== 'string') {
    throw new Error('Caminho inválido fornecido.');
  }

  // Prevenção de destruição catastrófica do sistema operacional
  const forbidden = ['/', '/etc', '/bin', '/sbin', '/usr', '/boot', '/dev', '/proc', '/sys', '/root'];
  const cleanPath = targetPath.trim().replace(/\/+$/, '');
  if (forbidden.includes(cleanPath)) {
    throw new Error(`Operação bloqueada por segurança no caminho crítico: ${cleanPath}`);
  }

  switch (operation) {
    case 'create_folder': {
      await mkdir(cleanPath, { recursive: true });
      return `Diretório criado com sucesso: ${cleanPath}`;
    }
    case 'delete_folder': {
      if (!existsSync(cleanPath)) return `Diretório não existe: ${cleanPath}`;
      await rm(cleanPath, { recursive: true, force: true });
      return `Diretório excluído com sucesso: ${cleanPath}`;
    }
    case 'write_file': {
      await writeFile(cleanPath, content, 'utf8');
      return `Arquivo salvo com sucesso (${content.length} caracteres): ${cleanPath}`;
    }
    case 'delete_file': {
      if (!existsSync(cleanPath)) return `Arquivo não existe: ${cleanPath}`;
      await rm(cleanPath, { force: true });
      return `Arquivo excluído com sucesso: ${cleanPath}`;
    }
    case 'read_file': {
      if (!existsSync(cleanPath)) return `Arquivo não existe: ${cleanPath}`;
      const content = await readFile(cleanPath, 'utf8');
      if (content.length > 50_000) {
        return content.slice(0, 50_000) + '\n... [arquivo truncado por exceder 50k caracteres]';
      }
      return content;
    }
    case 'list_directory': {
      if (!existsSync(cleanPath)) return `Diretório não existe: ${cleanPath}`;
      const entries = await readdir(cleanPath, { withFileTypes: true });
      const list = entries.map((e) => `${e.isDirectory() ? '[DIR] ' : '[FILE]'} ${e.name}`).join('\n');
      return list || '(diretório vazio)';
    }
    default:
      throw new Error(`Operação de arquivo desconhecida: ${operation}`);
  }
}
