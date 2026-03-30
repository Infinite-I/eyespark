enum CommandType {
  scan,
  navigate,
  stop,
  unknown,
}

class Command {
  final CommandType type;
  final String rawText;

  Command({
    required this.type,
    required this.rawText,
  });

  factory Command.fromText(String text) {
    final lower = text.toLowerCase();

    if (lower.contains('scan') || lower.contains('what')) {
      return Command(type: CommandType.scan, rawText: text);
    }

    if (lower.contains('go') || lower.contains('navigate')) {
      return Command(type: CommandType.navigate, rawText: text);
    }

    if (lower.contains('stop')) {
      return Command(type: CommandType.stop, rawText: text);
    }

    return Command(type: CommandType.unknown, rawText: text);
  }
}