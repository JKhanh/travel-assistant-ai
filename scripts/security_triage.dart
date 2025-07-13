#!/usr/bin/env dart
// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

/// Security triage script for processing GitLeaks and Semgrep scan results
/// This script processes security scan results and generates reports for PR comments
/// Usage: dart scripts/security_triage.dart [gitleaks-report.json] [semgrep-report.json]
class SecurityTriage {
  static const String version = '1.0.0';

  /// Process GitLeaks results and categorize by severity
  ///
  /// Analyzes GitLeaks findings and categorizes them based on:
  /// - Rule ID patterns (API keys, secrets, tokens)
  /// - File location (production vs test files)
  /// - Content context
  ///
  /// Returns categorized findings with summary statistics
  static Future<Map<String, dynamic>> processGitLeaksResults(
    String filePath,
  ) async {
    final file = File(filePath);
    if (!await file.exists()) {
      return {
        'summary': {
          'total': 0,
          'critical': 0,
          'high': 0,
          'medium': 0,
          'low': 0,
        },
        'findings': {'critical': [], 'high': [], 'medium': [], 'low': []},
      };
    }

    try {
      final content = await file.readAsString();
      final data = jsonDecode(content);

      // Check if this is an error report
      if (data is Map && data['status'] == 'error') {
        return {
          'status': 'error',
          'summary': {
            'total': 0,
            'critical': 0,
            'high': 0,
            'medium': 0,
            'low': 0,
          },
          'findings': {'critical': [], 'high': [], 'medium': [], 'low': []},
        };
      }

      // Otherwise, process as normal results array
      final results = (data is List) ? data : [];

      final Map<String, List<dynamic>> categorized = {
        'critical': [],
        'high': [],
        'medium': [],
        'low': [],
      };

      for (final result in results) {
        final severity = _determineSeverityGitLeaks(result);
        categorized[severity]?.add(result);
      }

      return {
        'summary': {
          'total': results.length,
          'critical': categorized['critical']?.length ?? 0,
          'high': categorized['high']?.length ?? 0,
          'medium': categorized['medium']?.length ?? 0,
          'low': categorized['low']?.length ?? 0,
        },
        'findings': categorized,
      };
    } catch (e) {
      print('Error processing GitLeaks results: $e');
      return {
        'summary': {
          'total': 0,
          'critical': 0,
          'high': 0,
          'medium': 0,
          'low': 0,
        },
        'findings': {'critical': [], 'high': [], 'medium': [], 'low': []},
      };
    }
  }

  /// Process Semgrep results and categorize by severity
  ///
  /// Analyzes Semgrep security findings and categorizes them based on:
  /// - Rule severity from Semgrep
  /// - OWASP classification
  /// - Impact assessment
  ///
  /// Returns categorized findings with summary statistics
  static Future<Map<String, dynamic>> processSemgrepResults(
    String filePath,
  ) async {
    final file = File(filePath);
    if (!await file.exists()) {
      return {
        'summary': {
          'total': 0,
          'critical': 0,
          'high': 0,
          'medium': 0,
          'low': 0,
        },
        'findings': {'critical': [], 'high': [], 'medium': [], 'low': []},
      };
    }

    try {
      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;

      // Check if this is an error report
      if (data['status'] == 'error') {
        return {
          'status': 'error',
          'summary': {
            'total': 0,
            'critical': 0,
            'high': 0,
            'medium': 0,
            'low': 0,
          },
          'findings': {'critical': [], 'high': [], 'medium': [], 'low': []},
        };
      }

      final results = data['results'] as List<dynamic>? ?? [];

      final Map<String, List<dynamic>> categorized = {
        'critical': [],
        'high': [],
        'medium': [],
        'low': [],
      };

      for (final result in results) {
        final severity = _determineSeveritySemgrep(result);
        categorized[severity]?.add(result);
      }

      return {
        'summary': {
          'total': results.length,
          'critical': categorized['critical']?.length ?? 0,
          'high': categorized['high']?.length ?? 0,
          'medium': categorized['medium']?.length ?? 0,
          'low': categorized['low']?.length ?? 0,
        },
        'findings': categorized,
      };
    } catch (e) {
      print('Error processing Semgrep results: $e');
      return {
        'summary': {
          'total': 0,
          'critical': 0,
          'high': 0,
          'medium': 0,
          'low': 0,
        },
        'findings': {'critical': [], 'high': [], 'medium': [], 'low': []},
      };
    }
  }

  /// Determine severity for GitLeaks findings based on rule and context
  ///
  /// Critical: Production API keys, database credentials, private keys
  /// High: Firebase configs, OAuth secrets, JWT keys
  /// Medium: Generic passwords, tokens in non-production files
  /// Low: Test data, examples, documentation
  static String _determineSeverityGitLeaks(Map<String, dynamic> finding) {
    final ruleId = finding['RuleID']?.toString().toLowerCase() ?? '';
    final file = finding['File']?.toString().toLowerCase() ?? '';

    // Skip test files and examples for severity assessment
    if (file.contains('test') ||
        file.contains('example') ||
        file.contains('docs') ||
        file.contains('.md')) {
      return 'low';
    }

    // Critical: Production secrets that could cause immediate security breach
    if (ruleId.contains('private-key') ||
        ruleId.contains('rsa-private-key') ||
        ruleId.contains('database-url') ||
        ruleId.contains('jwt-secret') ||
        (ruleId.contains('api-key') && !file.contains('test'))) {
      return 'critical';
    }

    // High: Configuration secrets and service credentials
    if (ruleId.contains('firebase') ||
        ruleId.contains('google-services') ||
        ruleId.contains('oauth') ||
        ruleId.contains('client-secret')) {
      return 'high';
    }

    // Medium: Generic secrets that may need attention
    if (ruleId.contains('password') ||
        ruleId.contains('token') ||
        ruleId.contains('secret')) {
      return 'medium';
    }

    return 'low';
  }

  /// Determine severity for Semgrep findings based on rule metadata
  ///
  /// Maps Semgrep severity levels to our categorization system
  /// Considers OWASP Top 10 classifications and impact ratings
  static String _determineSeveritySemgrep(Map<String, dynamic> finding) {
    final extra = finding['extra'] as Map<String, dynamic>? ?? {};
    final severity = extra['severity']?.toString().toLowerCase() ?? '';
    final ruleId = finding['check_id']?.toString().toLowerCase() ?? '';

    // Map Semgrep severity to our categories
    switch (severity) {
      case 'error':
        return 'critical';
      case 'warning':
        return 'high';
      case 'info':
        return 'medium';
      default:
        break;
    }

    // Check for specific security patterns
    if (ruleId.contains('injection') ||
        ruleId.contains('xss') ||
        ruleId.contains('deserialization')) {
      return 'critical';
    }

    if (ruleId.contains('crypto') ||
        ruleId.contains('auth') ||
        ruleId.contains('permission')) {
      return 'high';
    }

    return 'medium';
  }

  /// Generate comprehensive markdown report for PR comments
  ///
  /// Creates a formatted report combining GitLeaks and Semgrep results
  /// Includes summary statistics, critical findings, and remediation guidance
  static String generateMarkdownReport(
    Map<String, dynamic> gitLeaksAnalysis,
    Map<String, dynamic> semgrepAnalysis,
  ) {
    final gitLeaksSummary = gitLeaksAnalysis['summary'] as Map<String, dynamic>;
    final semgrepSummary = semgrepAnalysis['summary'] as Map<String, dynamic>;
    final gitLeaksFindings =
        gitLeaksAnalysis['findings'] as Map<String, List<dynamic>>;
    final semgrepFindings =
        semgrepAnalysis['findings'] as Map<String, List<dynamic>>;

    // Check if tools ran successfully
    final gitLeaksStatus = gitLeaksAnalysis['status'] as String?;
    final semgrepStatus = semgrepAnalysis['status'] as String?;

    final totalCritical =
        (gitLeaksSummary['critical'] as int) +
        (semgrepSummary['critical'] as int);
    final totalHigh =
        (gitLeaksSummary['high'] as int) + (semgrepSummary['high'] as int);
    final totalMedium =
        (gitLeaksSummary['medium'] as int) + (semgrepSummary['medium'] as int);
    final totalLow =
        (gitLeaksSummary['low'] as int) + (semgrepSummary['low'] as int);
    final totalFindings = totalCritical + totalHigh + totalMedium + totalLow;

    final buffer = StringBuffer();
    buffer.writeln('## 🔒 Security Scan Results (KAN-17)');
    buffer.writeln();

    // Add status warnings if tools failed
    if (gitLeaksStatus == 'error' || semgrepStatus == 'error') {
      buffer.writeln(
        '> ⚠️ **Warning**: Some security tools encountered issues during scanning',
      );
      buffer.writeln();
      if (gitLeaksStatus == 'error') {
        buffer.writeln(
          '> 🔴 **GitLeaks**: Failed to run properly. Check CI logs for details.',
        );
      }
      if (semgrepStatus == 'error') {
        buffer.writeln(
          '> 🔴 **Semgrep**: Failed to run properly. Check CI logs for details.',
        );
      }
      buffer.writeln();
    }

    // Summary table
    buffer.writeln('| Tool | Critical | High | Medium | Low | Total |');
    buffer.writeln('|------|----------|------|--------|-----|-------|');
    buffer.writeln(
      '| GitLeaks | ${gitLeaksSummary['critical']} | ${gitLeaksSummary['high']} | ${gitLeaksSummary['medium']} | ${gitLeaksSummary['low']} | ${gitLeaksSummary['total']} |',
    );
    buffer.writeln(
      '| Semgrep | ${semgrepSummary['critical']} | ${semgrepSummary['high']} | ${semgrepSummary['medium']} | ${semgrepSummary['low']} | ${semgrepSummary['total']} |',
    );
    buffer.writeln(
      '| **Total** | **$totalCritical** | **$totalHigh** | **$totalMedium** | **$totalLow** | **$totalFindings** |',
    );
    buffer.writeln();

    // Status indicator
    if (totalCritical > 0) {
      buffer.writeln(
        '🚨 **CRITICAL SECURITY ISSUES FOUND** - Merge blocked until resolved',
      );
    } else if (totalHigh > 0) {
      buffer.writeln(
        '⚠️ **High severity security issues found** - Review required',
      );
    } else if (totalMedium > 0) {
      buffer.writeln(
        '📋 **Medium severity issues found** - Consider addressing',
      );
    } else {
      buffer.writeln('✅ **No critical security issues found**');
    }
    buffer.writeln();

    // Critical findings section
    if (totalCritical > 0) {
      buffer.writeln('### 🚨 Critical Issues (Must Fix)');
      _addFindingsToReport(
        buffer,
        gitLeaksFindings['critical'] ?? [],
        'GitLeaks',
      );
      _addFindingsToReport(
        buffer,
        semgrepFindings['critical'] ?? [],
        'Semgrep',
      );
      buffer.writeln();
    }

    // High findings section
    if (totalHigh > 0) {
      buffer.writeln('### ⚠️ High Severity Issues');
      _addFindingsToReport(buffer, gitLeaksFindings['high'] ?? [], 'GitLeaks');
      _addFindingsToReport(buffer, semgrepFindings['high'] ?? [], 'Semgrep');
      buffer.writeln();
    }

    // Remediation guidance
    if (totalCritical > 0 || totalHigh > 0) {
      buffer.writeln('### 🛠️ Remediation Guidance');
      buffer.writeln(
        '1. **Remove hardcoded secrets** - Use environment variables or secure vaults',
      );
      buffer.writeln(
        '2. **Update .gitignore** - Ensure sensitive files are not tracked',
      );
      buffer.writeln(
        '3. **Rotate exposed credentials** - Immediately invalidate any leaked keys',
      );
      buffer.writeln(
        '4. **Review security practices** - Follow OWASP MASVS guidelines',
      );
      buffer.writeln();
    }

    buffer.writeln('---');
    buffer.writeln(
      '*🔍 Scanned with GitLeaks & Semgrep | Generated by KAN-17 Security Pipeline*',
    );

    return buffer.toString();
  }

  /// Add findings to markdown report with proper formatting
  ///
  /// Formats individual findings for inclusion in the markdown report
  /// Limits output to prevent overwhelming PR comments
  static void _addFindingsToReport(
    StringBuffer buffer,
    List<dynamic> findings,
    String tool,
  ) {
    if (findings.isEmpty) return;

    final maxFindings = 5; // Limit to prevent spam
    final displayFindings = findings.take(maxFindings).toList();

    for (final finding in displayFindings) {
      if (tool == 'GitLeaks') {
        final file = finding['File'] ?? 'Unknown';
        final line = finding['StartLine'] ?? '?';
        final rule = finding['RuleID'] ?? 'Unknown';
        buffer.writeln('- **$tool**: `$file:$line` - $rule');
      } else if (tool == 'Semgrep') {
        final file = finding['path'] ?? 'Unknown';
        final line = finding['start']?['line'] ?? '?';
        final ruleId = finding['check_id'] ?? 'Unknown';
        final message =
            finding['extra']?['message'] ?? 'Security issue detected';
        buffer.writeln('- **$tool**: `$file:$line` - $ruleId: $message');
      }
    }

    if (findings.length > maxFindings) {
      buffer.writeln(
        '- ... and ${findings.length - maxFindings} more $tool findings',
      );
    }
  }

  /// Combine GitLeaks and Semgrep analysis results
  ///
  /// Merges results from both tools into a unified analysis
  /// Used for overall security assessment and reporting
  static Map<String, dynamic> combineResults(
    Map<String, dynamic> gitLeaksAnalysis,
    Map<String, dynamic> semgrepAnalysis,
  ) {
    final gitLeaksSummary = gitLeaksAnalysis['summary'] as Map<String, dynamic>;
    final semgrepSummary = semgrepAnalysis['summary'] as Map<String, dynamic>;

    return {
      'summary': {
        'total':
            (gitLeaksSummary['total'] as int) +
            (semgrepSummary['total'] as int),
        'critical':
            (gitLeaksSummary['critical'] as int) +
            (semgrepSummary['critical'] as int),
        'high':
            (gitLeaksSummary['high'] as int) + (semgrepSummary['high'] as int),
        'medium':
            (gitLeaksSummary['medium'] as int) +
            (semgrepSummary['medium'] as int),
        'low': (gitLeaksSummary['low'] as int) + (semgrepSummary['low'] as int),
      },
      'gitleaks': gitLeaksAnalysis,
      'semgrep': semgrepAnalysis,
    };
  }
}

/// Main entry point for the security triage script
///
/// Processes command line arguments and orchestrates the security analysis
/// Outputs results in multiple formats for CI/CD pipeline consumption
void main(List<String> args) async {
  try {
    print('🔒 Security Triage Script v${SecurityTriage.version}');
    print('Processing security scan results...');

    // Default file paths
    String gitLeaksReport = 'gitleaks-report.json';
    String semgrepReport = 'semgrep-report.json';

    // Parse command line arguments
    if (args.isNotEmpty) {
      gitLeaksReport = args[0];
    }
    if (args.length > 1) {
      semgrepReport = args[1];
    }

    // Process both types of security scan results
    final gitLeaksAnalysis = await SecurityTriage.processGitLeaksResults(
      gitLeaksReport,
    );
    final semgrepAnalysis = await SecurityTriage.processSemgrepResults(
      semgrepReport,
    );
    final combinedAnalysis = SecurityTriage.combineResults(
      gitLeaksAnalysis,
      semgrepAnalysis,
    );

    // Generate markdown report for PR comments
    final markdown = SecurityTriage.generateMarkdownReport(
      gitLeaksAnalysis,
      semgrepAnalysis,
    );

    // Write outputs for GitHub Actions consumption
    await File('security-summary.md').writeAsString(markdown);
    await File(
      'security-analysis.json',
    ).writeAsString(jsonEncode(combinedAnalysis));

    // Console output for immediate feedback
    print('📊 Security Analysis Complete:');
    final summary = combinedAnalysis['summary'] as Map<String, dynamic>;
    print('  Critical: ${summary['critical']}');
    print('  High: ${summary['high']}');
    print('  Medium: ${summary['medium']}');
    print('  Low: ${summary['low']}');
    print('  Total: ${summary['total']}');

    // Exit with appropriate code for CI/CD pipeline
    final criticalCount = summary['critical'] as int;
    if (criticalCount > 0) {
      print('❌ Critical security issues found - failing build');
      exit(1);
    } else {
      print('✅ Security scan completed successfully');
      exit(0);
    }
  } catch (e, stackTrace) {
    print('💥 Error running security triage: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}
