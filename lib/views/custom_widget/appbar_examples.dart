import 'package:flutter/material.dart';
import 'custom_appbar.dart';

/// Example usage of CustomAppBar with different configurations
class AppBarExamples extends StatelessWidget {
  const AppBarExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Custom AppBar Examples',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            
            // Example 1: Basic AppBar with back button
            _buildExampleCard(
              context,
              'Basic AppBar with Back Button',
              'Standard app bar with back button enabled',
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExampleScreen(
                    title: 'Basic AppBar',
                    showBackButton: true,
                    curvedBottom: false,
                  ),
                ),
              ),
            ),
            
            // Example 2: AppBar without back button
            _buildExampleCard(
              context,
              'AppBar without Back Button',
              'App bar with back button disabled',
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExampleScreen(
                    title: 'No Back Button',
                    showBackButton: false,
                    curvedBottom: false,
                  ),
                ),
              ),
            ),
            
            // Example 3: AppBar with curved bottom
            _buildExampleCard(
              context,
              'AppBar with Curved Bottom',
              'App bar with curved bottom corners',
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExampleScreen(
                    title: 'Curved Bottom',
                    showBackButton: true,
                    curvedBottom: true,
                  ),
                ),
              ),
            ),
            
            // Example 4: AppBar with curved bottom and no back button
            _buildExampleCard(
              context,
              'Curved AppBar without Back Button',
              'App bar with curved bottom and no back button',
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExampleScreen(
                    title: 'Curved No Back',
                    showBackButton: false,
                    curvedBottom: true,
                  ),
                ),
              ),
            ),
            
            // Example 5: AppBar with custom border radius
            _buildExampleCard(
              context,
              'AppBar with Custom Border Radius',
              'App bar with custom curved bottom radius',
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExampleScreen(
                    title: 'Custom Radius',
                    showBackButton: true,
                    curvedBottom: true,
                    borderRadius: 30.0,
                  ),
                ),
              ),
            ),
            
            // Example 6: AppBar with loading indicator
            _buildExampleCard(
              context,
              'AppBar with Loading Indicator',
              'App bar with loading indicator in actions',
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExampleScreenWithLoading(
                    title: 'Loading AppBar',
                    showBackButton: true,
                    curvedBottom: true,
                    isLoading: true,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleCard(
    BuildContext context,
    String title,
    String description,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}

/// Example screen using CustomAppBar
class ExampleScreen extends StatelessWidget {
  final String title;
  final bool showBackButton;
  final bool curvedBottom;
  final double? borderRadius;

  const ExampleScreen({
    super.key,
    required this.title,
    required this.showBackButton,
    required this.curvedBottom,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: title,
        showBackButton: showBackButton,
        curvedBottom: curvedBottom,
        borderRadius: borderRadius,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search pressed')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('More options pressed')),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'AppBar Configuration:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('Back Button: ${showBackButton ? "Yes" : "No"}'),
            Text('Curved Bottom: ${curvedBottom ? "Yes" : "No"}'),
            if (borderRadius != null) Text('Border Radius: $borderRadius'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example screen using CustomAppBarWithLoading
class ExampleScreenWithLoading extends StatefulWidget {
  final String title;
  final bool showBackButton;
  final bool curvedBottom;
  final bool isLoading;

  const ExampleScreenWithLoading({
    super.key,
    required this.title,
    required this.showBackButton,
    required this.curvedBottom,
    required this.isLoading,
  });

  @override
  State<ExampleScreenWithLoading> createState() => _ExampleScreenWithLoadingState();
}

class _ExampleScreenWithLoadingState extends State<ExampleScreenWithLoading> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate loading for 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithLoading(
        title: widget.title,
        showBackButton: widget.showBackButton,
        curvedBottom: widget.curvedBottom,
        isLoading: _isLoading,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              });
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isLoading ? Icons.hourglass_empty : Icons.check_circle,
              size: 64,
              color: _isLoading 
                ? Theme.of(context).colorScheme.primary
                : Colors.green,
            ),
            const SizedBox(height: 16),
            Text(
              _isLoading ? 'Loading...' : 'Loading Complete!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('AppBar shows loading indicator: ${_isLoading ? "Yes" : "No"}'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
