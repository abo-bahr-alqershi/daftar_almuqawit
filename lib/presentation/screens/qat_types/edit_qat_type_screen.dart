import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/qat_type.dart';
import '../../blocs/qat_types/qat_types_bloc.dart';
import '../../blocs/qat_types/qat_types_event.dart';
import '../../blocs/qat_types/qat_types_state.dart';
import './widgets/qat_type_form.dart';
import '../../../core/services/qat_types_tutorial_service.dart';

/// شاشة تعديل نوع قات - تصميم راقي ونظيف
class EditQatTypeScreen extends StatefulWidget {
  final QatType qatType;

  const EditQatTypeScreen({super.key, required this.qatType});

  @override
  State<EditQatTypeScreen> createState() => _EditQatTypeScreenState();
}

class _EditQatTypeScreenState extends State<EditQatTypeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<QatTypeFormState>();
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  final GlobalKey _nameFieldKey = GlobalKey();
  final GlobalKey _qualityFieldKey = GlobalKey();
  final GlobalKey _saveButtonKey = GlobalKey();

  bool _showTutorial = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();

    _scrollController.addListener(() {
      setState(() => _scrollOffset = _scrollController.offset);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args != null &&
          args['showTutorial'] == true &&
          args['operation'] == 'edit') {
        setState(() => _showTutorial = true);
        _startTutorial();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    QatTypesTutorialService.dispose();
    super.dispose();
  }

  void _startTutorial() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted && _showTutorial) {
        await QatTypesTutorialService.showEditTutorial(
          context: context,
          nameFieldKey: _nameFieldKey,
          qualityFieldKey: _qualityFieldKey,
          saveButtonKey: _saveButtonKey,
          scrollController: _scrollController,
          onNext: () => setState(() => _showTutorial = false),
        );
      }
    });
  }

  Future<void> _submitQatType() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      HapticFeedback.lightImpact();
      return;
    }

    HapticFeedback.mediumImpact();
    final formData = _formKey.currentState!.getFormData();

    context.read<QatTypesBloc>().add(
      UpdateQatTypeEvent(
        QatType(
          id: widget.qatType.id,
          name: formData['name'],
          qualityGrade: formData['qualityGrade'],
          defaultBuyPrice: formData['defaultBuyPrice'],
          defaultSellPrice: formData['defaultSellPrice'],
          icon: formData['icon'],
          availableUnits: formData['availableUnits'],
          unitPrices: formData['unitPrices'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: BlocListener<QatTypesBloc, QatTypesState>(
          listener: (context, state) {
            if (state is QatTypeOperationSuccess) {
              HapticFeedback.heavyImpact();
              _showSnackBar(state.message, isError: false);
              Navigator.of(context).pop(true);
            } else if (state is QatTypesError) {
              HapticFeedback.heavyImpact();
              _showSnackBar(state.message, isError: true);
            }
          },
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: BlocBuilder<QatTypesBloc, QatTypesState>(
                      builder: (context, state) {
                        final isLoading = state is QatTypesLoading;

                        return Padding(
                          padding: const EdgeInsets.all(20),
                          child: QatTypeForm(
                            key: _formKey,
                            qatType: widget.qatType,
                            isLoading: isLoading,
                            nameFieldKey: _nameFieldKey,
                            qualityFieldKey: _qualityFieldKey,
                            saveButtonKey: _saveButtonKey,
                            onSubmit: _submitQatType,
                            onCancel: () {
                              HapticFeedback.lightImpact();
                              Navigator.of(context).pop();
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final opacity = (_scrollOffset / 60).clamp(0.0, 1.0);

    return SliverAppBar(
      expandedHeight: 100,
      pinned: true,
      backgroundColor: Colors.white.withOpacity(opacity),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 16,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _showTutorial = true);
              _startTutorial();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.help_outline,
                size: 20,
                color: Color(0xFF16A34A),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF16A34A).withOpacity(0.05),
                const Color(0xFFF8F9FA),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(60, 8, 20, 0),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0EA5E9), Color(0xFF38BDF8)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0EA5E9).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'تعديل نوع القات',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.qatType.name,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError
            ? const Color(0xFFDC2626)
            : const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }
}
