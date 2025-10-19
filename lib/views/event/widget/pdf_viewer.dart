import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import '../../../services/sharing_service.dart';

class PDFViewer extends StatefulWidget {
  final String pdfUrl;
  final String? title;

  const PDFViewer({
    super.key,
    required this.pdfUrl,
    this.title,
  });

  @override
  State<PDFViewer> createState() => _PDFViewerState();
}

class _PDFViewerState extends State<PDFViewer> {
  Uint8List? _pdfData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPDF();
  }

  Future<void> _loadPDF() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await http.get(Uri.parse(widget.pdfUrl));
      
      if (response.statusCode == 200) {
        setState(() {
          _pdfData = response.bodyBytes;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load PDF: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading PDF: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        // foregroundColor: Colors.white,
        elevation: 1,
        title: Text(
          widget.title ?? 'PDF Document',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_pdfData != null) ...[
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => _sharePDF(),
            ),
          ],
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading PDF...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading PDF',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPDF,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_pdfData != null) {
      return PdfPreview(
        allowPrinting: false,
        allowSharing: false,
        build: (format) => _pdfData!,
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        initialPageFormat: PdfPageFormat.a4,
        pdfFileName: widget.title ?? 'document.pdf',
        // onPrinted: (context) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(
        //       content: Text('PDF printed successfully'),
        //       backgroundColor: Colors.green,
        //     ),
        //   );
        // },
        // onShared: (context) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(
        //       content: Text('PDF shared successfully'),
        //       backgroundColor: Colors.blue,
        //     ),
        //   );
        // },
      );
    }

    return const Center(
      child: Text('No PDF data available'),
    );
  }

  Future<void> _printPDF() async {
    if (_pdfData != null) {
      await Printing.layoutPdf(
        onLayout: (format) => _pdfData!,
        name: widget.title ?? 'document.pdf',
      );
    }
  }

  Future<void> _sharePDF() async {
    try {
      if (_pdfData != null) {
        // Use the sharing service
        await SharingService.sharePDF(
          pdfData: _pdfData!,
          fileName: widget.title ?? 'PDF Document',
          context: context,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF not loaded yet'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

}
