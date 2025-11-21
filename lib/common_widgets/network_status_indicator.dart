import 'package:flutter/material.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
import 'package:smart_expense_tracker/services/network_service.dart';

/// Widget to display network connectivity status
class NetworkStatusIndicator extends StatefulWidget {
  const NetworkStatusIndicator({super.key});

  @override
  State<NetworkStatusIndicator> createState() => _NetworkStatusIndicatorState();
}

class _NetworkStatusIndicatorState extends State<NetworkStatusIndicator> {
  NetworkStatus _networkStatus = NetworkStatus.unknown;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _checkNetworkStatus();
  }

  Future<void> _checkNetworkStatus() async {
    setState(() {
      _isChecking = true;
    });

    try {
      final status = await NetworkService.checkNetworkStatus();
      setState(() {
        _networkStatus = status;
      });
    } catch (e) {
      setState(() {
        _networkStatus = NetworkStatus.unknown;
      });
    } finally {
      setState(() {
        _isChecking = false;
      });
    }
  }

  Color _getStatusColor() {
    switch (_networkStatus) {
      case NetworkStatus.connected:
        return Colors.green;
      case NetworkStatus.noInternet:
      case NetworkStatus.firebaseUnreachable:
        return Colors.red;
      case NetworkStatus.unknown:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon() {
    switch (_networkStatus) {
      case NetworkStatus.connected:
        return Icons.wifi;
      case NetworkStatus.noInternet:
        return Icons.wifi_off;
      case NetworkStatus.firebaseUnreachable:
        return Icons.cloud_off;
      case NetworkStatus.unknown:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getStatusColor().withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (_isChecking)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.getPrimaryColor(context),
                    ),
                  ),
                )
              else
                Icon(
                  _getStatusIcon(),
                  color: _getStatusColor(),
                  size: 16,
                ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isChecking 
                    ? 'Checking network...'
                    : NetworkService.getNetworkStatusMessage(_networkStatus),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.getSecondaryTextColor(context),
                  ),
                ),
              ),
              if (!_isChecking)
                IconButton(
                  onPressed: _checkNetworkStatus,
                  icon: Icon(
                    Icons.refresh,
                    size: 16,
                    color: AppTheme.getPrimaryColor(context),
                  ),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                ),
            ],
          ),
          if (_networkStatus != NetworkStatus.connected) ...[
            const SizedBox(height: 8),
            Text(
              'Tip: Check your internet connection and try again',
              style: TextStyle(
                fontSize: 10,
                color: AppTheme.getSecondaryTextColor(context),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
