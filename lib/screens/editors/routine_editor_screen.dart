import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/enums/routine_editor_type_enums.dart';
import 'package:tracker_app/models/ModelProvider.dart';
import 'package:tracker_app/providers/exercise_log_provider.dart';
import 'package:tracker_app/providers/routine_provider.dart';
import 'package:tracker_app/utils/snackbar_utils.dart';
import 'package:tracker_app/widgets/buttons/text_button_widget.dart';
import 'package:tracker_app/widgets/helper_widgets/dialog_helper.dart';
import 'package:tracker_app/screens/reorder_procedures_screen.dart';
import '../../app_constants.dart';
import '../../widgets/helper_widgets/routine_helper.dart';
import '../../widgets/routine/editors/exercise_log_widget.dart';
import '../../widgets/routine/editors/procedures_picker.dart';
import '../exercise/exercise_library_screen.dart';
import 'helper_utils.dart';

class RoutineEditorScreen extends StatefulWidget {
  final Routine? routine;

  const RoutineEditorScreen({super.key, this.routine});

  @override
  State<RoutineEditorScreen> createState() => _RoutineEditorScreenState();
}

class _RoutineEditorScreenState extends State<RoutineEditorScreen> with WidgetsBindingObserver {
  late TextEditingController _routineNameController;
  late TextEditingController _routineNotesController;

  bool _loading = false;
  String _loadingLabel = "";

  late Function _onDisposeCallback;

  void _showProceduresPicker({required ExerciseLogDto firstProcedure}) {
    final procedures = _whereOtherProceduresExcept(firstProcedure: firstProcedure);
    displayBottomSheet(
        context: context,
        child: ProceduresPicker(
          procedures: procedures,
          onSelect: (ExerciseLogDto secondProcedure) {
            _closeDialog();
            final id = "superset_id_${firstProcedure.exercise.id}_${secondProcedure.exercise.id}";
            Provider.of<ExerciseLogProvider>(context, listen: false).superSetExerciseLogs(
                firstExerciseLogId: firstProcedure.id, secondExerciseLogId: secondProcedure.id, superSetId: id);
          },
          onSelectExercisesInLibrary: () {
            _closeDialog();
            _selectExercisesInLibrary();
          },
        ));
  }

  /// Navigate to [ExerciseLibraryScreen]
  void _selectExercisesInLibrary() async {
    final provider = Provider.of<ExerciseLogProvider>(context, listen: false);
    final preSelectedExercises = provider.exerciseLogs.map((procedure) => procedure.exercise).toList();

    final exercises = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ExerciseLibraryScreen(preSelectedExercises: preSelectedExercises)))
        as List<Exercise>?;

    if (exercises != null && exercises.isNotEmpty) {
      if (mounted) {
        provider.addExerciseLogs(exercises: exercises);
      }
    }
  }

  void _reOrderProcedures() async {
    final provider = Provider.of<ExerciseLogProvider>(context, listen: false);
    final reOrderedList = await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return ReOrderProceduresScreen(procedures: List.from(provider.exerciseLogs));
      },
    ) as List<ExerciseLogDto>?;

    if (reOrderedList != null) {
      if (mounted) {
        provider.loadExerciseLogs(logs: reOrderedList, shouldNotifyListeners: true);
      }
    }
  }

  void _removeProcedureSuperSets({required String superSetId}) {
    Provider.of<ExerciseLogProvider>(context, listen: false).removeSuperSetForLogs(superSetId: superSetId);
  }

  void _removeProcedure({required String procedureId}) {
    Provider.of<ExerciseLogProvider>(context, listen: false).removeExerciseLog(logId: procedureId);
  }

  List<ExerciseLogDto> _whereOtherProceduresExcept({required ExerciseLogDto firstProcedure}) {
    return Provider.of<ExerciseLogProvider>(context, listen: false)
        .exerciseLogs
        .where((procedure) => procedure.id != firstProcedure.id && procedure.superSetId.isEmpty)
        .toList();
  }

  void _toggleLoadingState() {
    final routine = widget.routine;
    setState(() {
      _loading = !_loading;
      _loadingLabel = routine != null ? "Updating" : "Creating";
    });
  }

  bool _validateRoutineInputs() {
    final procedureProviders = Provider.of<ExerciseLogProvider>(context, listen: false);
    final procedures = procedureProviders.exerciseLogs;

    if (_routineNameController.text.isEmpty) {
      _showSnackbar('Please provide a name for this workout');
      return false;
    }
    if (procedures.isEmpty) {
      _showSnackbar("Workout must have exercise(s)");
      return false;
    }
    return true;
  }

  void _showSnackbar(String message) {
    showSnackbar(context: context, icon: const Icon(Icons.info_outline), message: message);
  }

  void _handleRoutineCreationError(String message) {
    if (mounted) {
      _showSnackbar(message);
    }
  }

  void _createRoutine() async {
    final procedureProvider = Provider.of<ExerciseLogProvider>(context, listen: false);
    final routineProvider = Provider.of<RoutineProvider>(context, listen: false);
    if (!_validateRoutineInputs()) return;
    _toggleLoadingState();
    try {
      await routineProvider.saveRoutine(
          name: _routineNameController.text.trim(),
          notes: _routineNotesController.text.trim(),
          procedures: procedureProvider.mergeSetsIntoExerciseLogs());
      if (mounted) _navigateBack();
    } catch (e) {
      _handleRoutineCreationError("Unable to create workout");
    } finally {
      _toggleLoadingState();
    }
  }

  void _updateRoutine() {
    if (!_validateRoutineInputs()) return;
    final routine = widget.routine;
    if (routine != null) {
      showAlertDialogWithMultiActions(
          context: context,
          message: "Update workout?",
          leftAction: _closeDialog,
          rightAction: () {
            _closeDialog();
            _doUpdateRoutine(routine: routine);
            _navigateBack();
          },
          leftActionLabel: 'Cancel',
          rightActionLabel: 'Update');
    }
  }

  void _doUpdateRoutine({required Routine routine, List<ExerciseLogDto>? updatedExerciseLogs}) async {
    final procedureProvider = Provider.of<ExerciseLogProvider>(context, listen: false);
    final exerciseLogs = updatedExerciseLogs ?? procedureProvider.mergeSetsIntoExerciseLogs();
    final routineProvider = Provider.of<RoutineProvider>(context, listen: false);
    _toggleLoadingState();
    try {
      final updatedRoutine = routine.copyWith(
          name: _routineNameController.text.trim(),
          notes: _routineNotesController.text.trim(),
          procedures: exerciseLogs.map((procedure) => procedure.toJson()).toList(),
          updatedAt: TemporalDateTime.now());
      await routineProvider.updateRoutine(routine: updatedRoutine);
    } catch (e) {
      _handleRoutineCreationError("Unable to update workout");
    } finally {
      _toggleLoadingState();
    }
  }

  void _checkForUnsavedChanges() {
    final procedureProvider = Provider.of<ExerciseLogProvider>(context, listen: false);
    final oldProcedures = widget.routine?.procedures;
    final exerciseLog1 = oldProcedures?.map((json) => ExerciseLogDto.fromJson(json: jsonDecode(json))).toList();
    final exerciseLog2 = procedureProvider.mergeSetsIntoExerciseLogs();
    final unsavedChangesMessage =
        checkForChanges(context: context, exerciseLog1: exerciseLog1 ?? [], exerciseLog2: exerciseLog2);
    if (unsavedChangesMessage.isNotEmpty) {
      showAlertDialogWithMultiActions(
          context: context,
          message: "You have unsaved changes",
          leftAction: _closeDialog,
          leftActionLabel: 'Cancel',
          rightAction: () {
            _closeDialog();
            _navigateBack();
          },
          rightActionLabel: 'Discard',
          isRightActionDestructive: true);
    } else {
      _navigateBack();
    }
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void _closeDialog() {
    Navigator.of(context).pop();
  }

  void _navigateBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final routine = widget.routine;

    final exerciseLogs = context.select((ExerciseLogProvider provider) => provider.exerciseLogs);

    bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom != 0;

    return Scaffold(
        backgroundColor: tealBlueDark,
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back_outlined), onPressed: _checkForUnsavedChanges),
          actions: [
            CTextButton(
                onPressed: routine != null ? _updateRoutine : _createRoutine,
                label: routine != null ? "Update" : "Save",
                buttonColor: Colors.transparent,
                loading: _loading,
                loadingLabel: _loadingLabel)
          ],
        ),
        floatingActionButton: isKeyboardOpen
            ? null
            : FloatingActionButton(
                heroTag: "fab_select_exercise_log_screen",
                onPressed: _selectExercisesInLibrary,
                backgroundColor: tealBlueLighter,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                child: const Icon(Icons.add, size: 28),
              ),
        body: NotificationListener<UserScrollNotification>(
          onNotification: (scrollNotification) {
            if (scrollNotification.direction != ScrollDirection.idle) {
              _dismissKeyboard();
            }
            return false;
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 10.0, bottom: 10.0, left: 10.0),
            child: GestureDetector(
              onTap: _dismissKeyboard,
              child: Column(
                children: [
                  Column(
                    children: [
                      TextField(
                        controller: _routineNameController,
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(2),
                                borderSide: const BorderSide(color: tealBlueLighter)),
                            filled: true,
                            fillColor: tealBlueLighter,
                            hintText: "New workout",
                            hintStyle: GoogleFonts.lato(color: Colors.grey, fontSize: 14)),
                        cursorColor: Colors.white,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.words,
                        style: GoogleFonts.lato(
                            fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.8), fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _routineNotesController,
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(2),
                                borderSide: const BorderSide(color: tealBlueLighter)),
                            filled: true,
                            fillColor: tealBlueLighter,
                            hintText: "Notes",
                            hintStyle: GoogleFonts.lato(color: Colors.grey, fontSize: 14)),
                        maxLines: null,
                        cursorColor: Colors.white,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                        style: GoogleFonts.lato(
                            fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.8), fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                      child: ListView.separated(
                          padding: const EdgeInsets.only(bottom: 250),
                          itemBuilder: (BuildContext context, int index) {
                            final procedure = exerciseLogs[index];
                            final procedureId = procedure.id;
                            return ExerciseLogWidget(
                                exerciseLogDto: procedure,
                                editorType: RoutineEditorMode.edit,
                                superSet:
                                    whereOtherSuperSetProcedure(firstProcedure: procedure, procedures: exerciseLogs),
                                onRemoveSuperSet: (String superSetId) =>
                                    _removeProcedureSuperSets(superSetId: procedure.superSetId),
                                onRemoveLog: () => _removeProcedure(procedureId: procedureId),
                                onSuperSet: () => _showProceduresPicker(firstProcedure: procedure),
                                onReOrderLogs: _reOrderProcedures);
                          },
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemCount: exerciseLogs.length)),
                ],
              ),
            ),
          ),
        ));
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _initializeProcedureData();
    _initializeTextControllers();

    _onDisposeCallback = Provider.of<ExerciseLogProvider>(context, listen: false).onClearProvider;
  }

  void _initializeProcedureData() {
    final procedureJsons = widget.routine?.procedures;
    final procedures = procedureJsons?.map((json) => ExerciseLogDto.fromJson(json: jsonDecode(json))).toList();
    if (procedures != null) {
      Provider.of<ExerciseLogProvider>(context, listen: false).loadExerciseLogs(logs: procedures);
    }
  }

  void _initializeTextControllers() {
    Routine? routine = widget.routine;
    _routineNameController = TextEditingController(text: routine?.name);
    _routineNotesController = TextEditingController(text: routine?.notes);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _onDisposeCallback();
    _routineNameController.dispose();
    _routineNotesController.dispose();
    super.dispose();
  }
}
