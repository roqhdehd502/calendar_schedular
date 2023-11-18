import 'package:calendar_schedular/component/custom_text_field.dart';
import 'package:calendar_schedular/const/colors.dart';
import 'package:calendar_schedular/database/drift_database.dart';
import 'package:calendar_schedular/util/gap.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ScheduleBottomSheet extends StatefulWidget {
  final int? scheduleId;
  final DateTime selectedDate;

  const ScheduleBottomSheet({
    this.scheduleId,
    required this.selectedDate,
    super.key,
  });

  @override
  State<ScheduleBottomSheet> createState() => _ScheduleBottomSheetState();
}

class _ScheduleBottomSheetState extends State<ScheduleBottomSheet> {
  final GlobalKey<FormState> formKey = GlobalKey();

  int? startTime;
  int? endTime;
  String? content;
  int? selectedColorId;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: FutureBuilder<Schedule>(
        future: widget.scheduleId == null
            ? null
            : GetIt.I<LocalDatabase>().getScheduleById(widget.scheduleId!),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('스케쥴을 불러올 수 없습니다.'),
            );
          }
          if (snapshot.connectionState != ConnectionState.none &&
              !snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData && startTime == null) {
            startTime = snapshot.data!.startTime;
            endTime = snapshot.data!.endTime;
            content = snapshot.data!.content;
            selectedColorId = snapshot.data!.colorId;
          }

          return SafeArea(
            child: Container(
              height: MediaQuery.of(context).size.height / 2 + bottomInset,
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.only(bottom: bottomInset),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 8.0,
                    right: 8.0,
                    top: 16.0,
                  ),
                  child: Form(
                    key: formKey,
                    // autovalidateMode: AutovalidateMode.always,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Time(
                          startInitialValue: startTime?.toString() ?? '',
                          endInitialValue: endTime?.toString() ?? '',
                          onStartSaved: (String? val) {
                            startTime = int.parse(val!);
                          },
                          onEndSaved: (String? val) {
                            endTime = int.parse(val!);
                          },
                        ),
                        const Gap(height: 16.0),
                        _Content(
                          contentInitialValue: content ?? '',
                          onContentSaved: (String? val) {
                            content = val;
                          },
                        ),
                        const Gap(height: 16.0),
                        FutureBuilder<List<CategoryColor>>(
                          future: GetIt.I<LocalDatabase>().getCategoryColors(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData &&
                                selectedColorId == null &&
                                snapshot.data!.isNotEmpty) {
                              selectedColorId = snapshot.data![0].id;
                            }
                            return _ColorPicker(
                              colors: snapshot.hasData ? snapshot.data! : [],
                              selectedColorId: selectedColorId,
                              colorIdSetter: (int id) {
                                setState(() {
                                  selectedColorId = id;
                                });
                              },
                            );
                          },
                        ),
                        const Gap(width: 8.0),
                        _SaveButton(onPressed: onSavePressed),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void onSavePressed() async {
    if (formKey.currentState == null) {
      return;
    }

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      if (widget.scheduleId == null) {
        await GetIt.I<LocalDatabase>().createSchedule(
          SchedulesCompanion(
            colorId: Value(selectedColorId!),
            content: Value(content!),
            date: Value(widget.selectedDate),
            startTime: Value(startTime!),
            endTime: Value(endTime!),
          ),
        );
      } else {
        await GetIt.I<LocalDatabase>().updateScheduleById(
          widget.scheduleId!,
          SchedulesCompanion(
            colorId: Value(selectedColorId!),
            content: Value(content!),
            date: Value(widget.selectedDate),
            startTime: Value(startTime!),
            endTime: Value(endTime!),
          ),
        );
      }

      Navigator.of(context).pop();
    } else {
      print('SAVE FAILED!');
      return;
    }
  }
}

class _Time extends StatelessWidget {
  final String startInitialValue;
  final String endInitialValue;
  final FormFieldSetter<String> onStartSaved;
  final FormFieldSetter<String> onEndSaved;

  const _Time({
    required this.startInitialValue,
    required this.endInitialValue,
    required this.onStartSaved,
    required this.onEndSaved,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            label: '시작시간',
            initialValue: startInitialValue,
            isTime: true,
            onSaved: onStartSaved,
          ),
        ),
        const Gap(width: 16.0),
        Expanded(
          child: CustomTextField(
            label: '마감시간',
            initialValue: endInitialValue,
            isTime: true,
            onSaved: onEndSaved,
          ),
        ),
      ],
    );
  }
}

class _Content extends StatelessWidget {
  final String contentInitialValue;
  final FormFieldSetter<String> onContentSaved;

  const _Content({
    required this.contentInitialValue,
    required this.onContentSaved,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CustomTextField(
        label: '내용',
        initialValue: contentInitialValue,
        isTime: false,
        onSaved: onContentSaved,
      ),
    );
  }
}

typedef ColorIdSetter = void Function(int id);

class _ColorPicker extends StatelessWidget {
  final List<CategoryColor> colors;
  final int? selectedColorId;
  final ColorIdSetter colorIdSetter;

  const _ColorPicker({
    required this.colors,
    required this.selectedColorId,
    required this.colorIdSetter,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 10.0,
      children: colors
          .map(
            (e) => GestureDetector(
              onTap: () {
                colorIdSetter(e.id);
              },
              child: renderColor(
                e,
                selectedColorId == e.id,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget renderColor(CategoryColor color, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(
          int.parse(
            'FF${color.hexCode}',
            radix: 16,
          ),
        ),
        border: isSelected
            ? Border.all(
                color: Colors.black,
                width: 4.0,
              )
            : null,
      ),
      width: 32.0,
      height: 32.0,
    );
  }
}

class _SaveButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SaveButton({
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: PRIMARY_COLOR,
            ),
            child: const Text('저장'),
          ),
        ),
      ],
    );
  }
}
