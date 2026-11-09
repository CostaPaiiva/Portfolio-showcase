import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/api_service.dart';
import '../services/chat_storage.dart';
import '../widgets/formatted_chat_message.dart';

class ChatMessageItem {
  ChatMessageItem({required this.role, required this.text});
  final String role; // 'user' ou 'model'
  final String text;

  Map<String, dynamic> toMap() => {'role': role, 'text': text};

  factory ChatMessageItem.fromMap(Map<String, dynamic> map) => ChatMessageItem(
        role: map['role'] as String? ?? 'user',
        text: map['text'] as String? ?? '',
      );
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.api});
  final ApiService api;

  @override
  State<ChatScreen> createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  static const String _defaultWelcomeText =
      'Olá Thiago! Sou seu Copiloto SysAdmin para a VPS.\n\nAgora você pode falar comigo por texto ou por voz usando o microfone 🎙️!\n\nPosso executar diagnósticos no terminal, verificar uso de CPU/RAM, inspecionar logs de containers e serviços do sistema.';

  final ChatStorage _chatStorage = ChatStorage();
  List<ChatMessageItem> _messages = [
    ChatMessageItem(
      role: 'model',
      text: _defaultWelcomeText,
    ),
  ];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _loading = false;
  bool _isListening = false;
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _initSpeech();
  }

  Future<void> _loadHistory() async {
    final saved = await _chatStorage.loadMessages();
    if (saved != null && saved.isNotEmpty && mounted) {
      setState(() {
        _messages = saved;
      });
      _scrollToBottom();
    }
  }

  Future<void> clearChat() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpar conversa?'),
        content: const Text(
            'Todas as mensagens do Copiloto serão apagadas do dispositivo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await _chatStorage.clearMessages();
      setState(() {
        _messages = [
          ChatMessageItem(
            role: 'model',
            text: _defaultWelcomeText,
          ),
        ];
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conversa do Copiloto limpa com sucesso.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _initSpeech() async {
    try {
      final available = await _speech.initialize(
        onError: (val) {
          if (mounted) setState(() => _isListening = false);
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted) setState(() => _isListening = false);
          }
        },
      );
      if (mounted) setState(() => _speechAvailable = available);
    } catch (_) {
      if (mounted) setState(() => _speechAvailable = false);
    }
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    if (!_speechAvailable) {
      await _initSpeech();
      if (!_speechAvailable) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Reconhecimento de voz indisponível ou permissão negada.')),
          );
        }
        return;
      }
    }

    setState(() => _isListening = true);
    await _speech.listen(
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.dictation,
        cancelOnError: true,
      ),
      onResult: (result) {
        setState(() {
          _controller.text = result.recognizedWords;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        });
      },
    );
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading) return;

    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    }

    _controller.clear();
    setState(() {
      _messages.add(ChatMessageItem(role: 'user', text: text));
      _loading = true;
    });
    _chatStorage.saveMessages(_messages);

    _scrollToBottom();

    try {
      final payload =
          _messages.map((m) => {'role': m.role, 'content': m.text}).toList();
      final reply = await widget.api.sendChatMessage(payload);

      if (mounted) {
        setState(() {
          _messages.add(ChatMessageItem(role: 'model', text: reply));
        });
        await _chatStorage.saveMessages(_messages);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessageItem(
              role: 'model',
              text: '⚠️ Erro ao comunicar com o servidor: $e',
            ),
          );
        });
        await _chatStorage.saveMessages(_messages);
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _speech.stop();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              final isUser = msg.role == 'user';

              return Align(
                alignment:
                    isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.85,
                  ),
                  decoration: BoxDecoration(
                    color: isUser
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isUser
                          ? const Radius.circular(16)
                          : const Radius.circular(2),
                      bottomRight: isUser
                          ? const Radius.circular(2)
                          : const Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FormattedChatMessage(
                        text: msg.text,
                        isUser: isUser,
                        textColor: isUser
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                      ),
                      if (!isUser) ...[
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: msg.text));
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Mensagem copiada para a área de transferência! 📋'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.copy_rounded,
                                    size: 13,
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Copiar',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (_loading)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 10),
                Text(
                  'Copiloto pensando...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        // Chips de Comandos Rápidos
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              _buildQuickPromptChip('📊 Status da VPS', 'Como está o status geral da VPS?'),
              const SizedBox(width: 8),
              _buildQuickPromptChip('🐳 Containers Docker', 'Liste os containers docker ativos e parados'),
              const SizedBox(width: 8),
              _buildQuickPromptChip('💾 Uso de Disco', 'Verifique o espaço em disco e partições'),
              const SizedBox(width: 8),
              _buildQuickPromptChip('⚠️ Verificar Alertas', 'Quais alertas ou problemas existem no sistema?'),
              const SizedBox(width: 8),
              _buildQuickPromptChip('⚡ Uso de CPU/RAM', 'Qual o consumo atual de memória RAM e CPU?'),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2)),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                IconButton(
                  tooltip: _isListening ? 'Parar gravação' : 'Falar por áudio',
                  icon: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: _isListening
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                  ),
                  onPressed: _loading ? null : _toggleListening,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: _isListening
                          ? 'Ouvindo sua voz...'
                          : 'Pergunte ou envie um comando...',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.4),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.arrow_upward_rounded),
                  onPressed: _loading ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickPromptChip(String label, String prompt) {
    return ActionChip(
      avatar: null,
      label: Text(label, style: const TextStyle(fontSize: 12)),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.15)),
      onPressed: _loading
          ? null
          : () {
              _controller.text = prompt;
              _sendMessage();
            },
    );
  }
}
