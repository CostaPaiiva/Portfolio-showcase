import { exec } from 'node:child_process';
import { promisify } from 'node:util';

const execAsync = promisify(exec);

export async function executeCommand(command: string): Promise<string> {
  if (!command || typeof command !== 'string') {
    throw new Error('Comando inválido.');
  }

  // Prevenção contra acidentes catastróficos irreversíveis
  const trimmed = command.trim();
  const dangerousPatterns = [
    /\brm\s+-[rfR]*\s+[\/\*]/,
    /\bmkfs\b/,
    /\bdd\s+if=/,
    />\s*\/dev\/sd/,
    /:(){ :|:& };:/,
  ];

  for (const pattern of dangerousPatterns) {
    if (pattern.test(trimmed)) {
      throw new Error(`Comando bloqueado por segurança: padrão de risco detectado.`);
    }
  }

  try {
    const { stdout, stderr } = await execAsync(trimmed, {
      timeout: 60_000,
      maxBuffer: 10 * 1024 * 1024,
    });

    const output = (stdout || stderr || 'Comando executado sem retorno de texto.').trim();
    // Limitar para não estourar contexto do LLM
    if (output.length > 50_000) {
      return output.slice(0, 50_000) + '\n... [saída truncada por exceder 50k caracteres]';
    }
    return output;
  } catch (error: any) {
    const errOutput = (error.stdout ? error.stdout + '\n' : '') + (error.stderr || error.message || String(error));
    return `Falha na execução (código ${error.code ?? 'erro'}):\n${errOutput.trim()}`;
  }
}
