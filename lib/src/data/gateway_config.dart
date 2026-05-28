import 'package:flutter_dotenv/flutter_dotenv.dart';

class GatewayConfig {
  const GatewayConfig({required this.envName, required this.gatewayUrl});

  static const String defaultGatewayUrl = 'http://127.0.0.1:8888';
  static const String defaultEnvName = 'dev';

  static GatewayConfig get current {
    const envName = String.fromEnvironment(
      'AIM_ENV_NAME',
      defaultValue: defaultEnvName,
    );
    const gatewayUrl = String.fromEnvironment(
      'AIM_GATEWAY_URL',
      defaultValue: '',
    );
    final dotenvEnvName = dotenv.isInitialized
        ? dotenv.maybeGet('AIM_ENV_NAME')
        : null;
    final dotenvGatewayUrl = dotenv.isInitialized
        ? dotenv.maybeGet('AIM_GATEWAY_URL')
        : null;
    return GatewayConfig(
      envName: dotenvEnvName ?? envName,
      gatewayUrl:
          dotenvGatewayUrl ??
          (gatewayUrl.isEmpty ? defaultGatewayUrl : gatewayUrl),
    );
  }

  final String envName;
  final String gatewayUrl;

  Uri get baseUri => Uri.parse(gatewayUrl);

  Uri get wsUri {
    final uri = baseUri;
    final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
    return uri.replace(scheme: scheme, path: '/ws', query: '');
  }

  bool get isLocal =>
      gatewayUrl.contains('127.0.0.1') || gatewayUrl.contains('localhost');

  String get description => '$envName@$gatewayUrl';

  GatewayConfig copyWith({String? envName, String? gatewayUrl}) {
    return GatewayConfig(
      envName: envName ?? this.envName,
      gatewayUrl: gatewayUrl ?? this.gatewayUrl,
    );
  }
}
