import 'package:flutter/material.dart';
import '../../domain/entities/verification.dart';

/// Badge visual para mostrar el estado de verificación de un usuario
class VerificationBadgeWidget extends StatelessWidget {
  final Verification? verification;
  final int verifiedReferencesCount;
  final bool showLabel;
  final double size;

  const VerificationBadgeWidget({
    super.key,
    this.verification,
    this.verifiedReferencesCount = 0,
    this.showLabel = true,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    // Determinar el estado de verificación
    final bool hasVerification = verification?.status == 'verified';
    final bool hasReferences = verifiedReferencesCount > 0;
    
    // Si no tiene verificación ni referencias, no mostrar nada
    if (!hasVerification && !hasReferences) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size * 0.5,
        vertical: size * 0.25,
      ),
      decoration: BoxDecoration(
        color: _getBackgroundColor(hasVerification),
        borderRadius: BorderRadius.circular(size),
        border: Border.all(
          color: _getBorderColor(hasVerification),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIcon(hasVerification),
            size: size,
            color: _getIconColor(hasVerification),
          ),
          if (showLabel) ...[
            SizedBox(width: size * 0.3),
            Text(
              _getLabel(hasVerification),
              style: TextStyle(
                fontSize: size * 0.6,
                fontWeight: FontWeight.bold,
                color: _getIconColor(hasVerification),
              ),
            ),
          ],
          if (hasReferences && showLabel) ...[
            SizedBox(width: size * 0.2),
            Text(
              '($verifiedReferencesCount)',
              style: TextStyle(
                fontSize: size * 0.5,
                color: _getIconColor(hasVerification)
                    .withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getIcon(bool hasVerification) {
    if (hasVerification) {
      return Icons.verified_user;
    }
    return Icons.star;
  }

  Color _getIconColor(bool hasVerification) {
    if (hasVerification) {
      return Colors.blue;
    }
    if (verifiedReferencesCount >= 3) {
      return Colors.green;
    }
    return Colors.orange;
  }

  Color _getBackgroundColor(bool hasVerification) {
    return _getIconColor(hasVerification).withOpacity(0.1);
  }

  Color _getBorderColor(bool hasVerification) {
    return _getIconColor(hasVerification).withOpacity(0.3);
  }

  String _getLabel(bool hasVerification) {
    if (hasVerification) {
      return 'Verificado';
    }
    if (verifiedReferencesCount >= 3) {
      return 'Con referencias';
    }
    return 'Referencias';
  }
}

/// Widget expandido con más información sobre la verificación
class VerificationInfoCard extends StatelessWidget {
  final Verification? verification;
  final int totalReferences;
  final int verifiedReferencesCount;

  const VerificationInfoCard({
    super.key,
    this.verification,
    this.totalReferences = 0,
    this.verifiedReferencesCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.security, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Verificación y Confianza',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Estado de verificación de identidad
            _buildInfoRow(
              context,
              'Verificación de identidad',
              verification != null
                  ? _getVerificationStatusText(verification!.status)
                  : 'No verificado',
              _getVerificationIcon(verification?.status),
              _getVerificationColor(verification?.status),
            ),
            
            const SizedBox(height: 12),
            
            // Referencias
            _buildInfoRow(
              context,
              'Referencias verificadas',
              '$verifiedReferencesCount de $totalReferences',
              Icons.people,
              verifiedReferencesCount > 0 ? Colors.green : Colors.grey,
            ),
            
            if (totalReferences > 0) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: totalReferences > 0
                    ? verifiedReferencesCount / totalReferences
                    : 0,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation(
                  verifiedReferencesCount >= 3 ? Colors.green : Colors.orange,
                ),
              ),
            ],
            
            if (verification == null && totalReferences == 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Verifica tu identidad y agrega referencias para aumentar tu confiabilidad',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _getVerificationStatusText(String status) {
    switch (status) {
      case 'verified':
        return 'Verificado';
      case 'pending':
        return 'Pendiente';
      case 'rejected':
        return 'Rechazado';
      default:
        return 'Sin verificar';
    }
  }

  IconData _getVerificationIcon(String? status) {
    switch (status) {
      case 'verified':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  Color _getVerificationColor(String? status) {
    switch (status) {
      case 'verified':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}