import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kompas/controller/achievementTracker_controller.dart';
import 'package:kompas/controller/tripData_controller.dart';
import 'package:kompas/controller/tripState_controller.dart';
import 'package:kompas/statics/colors.dart';
import 'package:kompas/statics/constants.dart';
import 'package:kompas/statics/text_styles.dart';
import 'package:kompas/model/tripDatabase.dart';
import 'package:kompas/widgets/tripStepSelectBox_widget.dart';

/// Displays trip content based on step type
class TripViewStepSwitch extends StatelessWidget {
  TripViewStepSwitch({
    Key? key,
    required this.tripDataController,
    required this.tripStateController,
    required this.tripDataSelect,
  }) : super(key: key);

  final TripDataController tripDataController;
  final TripStateController tripStateController;
  final TripDataSelect tripDataSelect;

  final ScrollController _scrollController = ScrollController(keepScrollOffset: false);

  @override
  Widget build(BuildContext context) {
    final AchievementTrackerController _achievementTrackerController = Get.find();

    switch (tripDataController.getStepItem(tripDataSelect: tripDataSelect).type) {
      case StepType.info:
        return Expanded(
          child: Scrollbar(
            thumbVisibility: true,
            controller: _scrollController,
            child: ListView(
              // start with scroll position on top (key and controller)
              key: Key(tripStateController.getCurrentStep().toString()),
              controller: _scrollController,
              padding: EdgeInsets.fromLTRB(Constants.insideMargin, 0, Constants.insideMargin, Constants.insideMargin),
              children: [
                Container(
                  alignment: Alignment.topCenter,
                  margin: EdgeInsets.symmetric(horizontal: Constants.insideMargin),
                  child: Text(tripDataController.getStepItem(tripDataSelect: tripDataSelect).caption,
                      style: AppTextStyles.paragraphSubtext.copyWith(color: AppColors.secondaryNormal),
                      textAlign: TextAlign.center),
                ),
                Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.all(Constants.insideMargin),
                  child: Text(
                    tripDataController.getStepItem(tripDataSelect: tripDataSelect).title,
                    style: AppTextStyles.headerH3.copyWith(color: AppColors.primaryDark),
                  ),
                ),
                Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.all(Constants.insideMargin),
                  child: Text(
                    tripDataController.getStepItem(tripDataSelect: tripDataSelect).description,
                    style: AppTextStyles.paragraphText.copyWith(color: AppColors.primaryDark),
                  ),
                ),
              ],
            ),
          ),
        );
      case StepType.select:
        int selectionLength = tripDataController.getStepItem(tripDataSelect: tripDataSelect).selection.length;
        return Expanded(
          child: GridView.count(
            padding: EdgeInsets.all(Constants.insideMargin),
            scrollDirection: getAxisLayout(),
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: selectionLength ~/ 2, // truncated division
            crossAxisSpacing: Constants.insideMargin,
            mainAxisSpacing: Constants.insideMargin,
            children: List<Widget>.generate(selectionLength, (int index) {
              return TripStepSelectBox(
                boxView: true,
                tripDataSelect: tripDataSelect,
                selectionNum: index,
                boxColor: AppColors.selectionColorList[index],
              );
            }),
          ),
        );
      case StepType.selectList:
        int selectionLength = tripDataController.getStepItem(tripDataSelect: tripDataSelect).selection.length;
        return Expanded(
          child: ListView.separated(
              separatorBuilder: (context, index) {
                return SizedBox(height: Constants.minMargin); // Adjust the height as per your requirement
              },
              padding: EdgeInsets.all(Constants.insideMargin),
              scrollDirection: Axis.vertical,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: selectionLength,
              itemBuilder: (context, index) {
                return TripStepSelectBox(
                  boxView: false, // show rows to select
                  tripDataSelect: tripDataSelect,
                  selectionNum: index,
                  boxColor: AppColors.selectionColorList[index],
                );
              }),
        );
      case StepType.answer:
        if (_correctAnswer(tripDataSelect))
          _achievementTrackerController.incrementAnswerScore(
              tripDataController.getTripItem(index: tripDataSelect.tripIndex).uid, tripDataSelect.stepIndex);
        //AchievementScore.addAnswerScore; //TODO: mk where should achievementScore (an instance of AchievementScore class) be instantiated?
        //TODO: mk how can I keep score even if the app is closed?
        //TODO: introduce achievements class where score for correct answers and finished trips is keps
        //TODO: initialize with 0, add methods for adding score and add logic for not counting score and finished trips twice
        //TODO remove mk
        return Expanded(
          child: Scrollbar(
            thumbVisibility: true,
            controller: _scrollController,
            child: ListView(
              // start with scroll position on top (key and controller)
              key: Key(tripStateController.getCurrentStep().toString()),
              controller: _scrollController,
              padding: EdgeInsets.all(Constants.insideMargin),
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.all(Constants.insideMargin),
                  child: Text(
                    tripDataController.getStepItem(tripDataSelect: tripDataSelect).title,
                    style: AppTextStyles.headerH3.copyWith(color: AppColors.primaryDark),
                  ),
                ),
                if (_correctAnswer(tripDataSelect))
                  Container(
                    alignment: Alignment.topLeft,
                    margin: EdgeInsets.all(Constants.insideMargin),
                    child: Text(
                      tripDataController.getStepItem(tripDataSelect: tripDataSelect).correctAnswer,
                      style: AppTextStyles.paragraphText.copyWith(color: AppColors.primaryDark),
                    ),
                  )
                else
                  Container(
                    alignment: Alignment.topLeft,
                    margin: EdgeInsets.all(Constants.insideMargin),
                    child: Text(
                      tripDataController.getStepItem(tripDataSelect: tripDataSelect).incorrectAnswer,
                      style: AppTextStyles.paragraphText.copyWith(color: AppColors.primaryDark),
                    ),
                  ),
              ],
            ),
          ),
        );
      case StepType.end:
        _achievementTrackerController
            .incrementTripScore(tripDataController.getTripItem(index: tripDataSelect.tripIndex).uid);
        return Expanded(
          child: Scrollbar(
            thumbVisibility: true,
            controller: _scrollController,
            child: ListView(
              // start with scroll position on top (key and controller)
              key: Key(tripStateController.getCurrentStep().toString()),
              controller: _scrollController,
              padding: EdgeInsets.all(Constants.insideMargin),
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.all(Constants.insideMargin),
                  child: Text(
                    tripDataController.getStepItem(tripDataSelect: tripDataSelect).title,
                    style: AppTextStyles.headerH3.copyWith(color: AppColors.primaryDark),
                  ),
                ),
                Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.all(Constants.insideMargin),
                  child: Text(
                    tripDataController.getStepItem(tripDataSelect: tripDataSelect).description,
                    style: AppTextStyles.paragraphText.copyWith(color: AppColors.primaryDark),
                  ),
                ),
              ],
            ),
          ),
        );
      default:
        assert(false, 'TripViewStepSwitch must have a valid switch type');
        return Container();
    }
  }

  bool _correctAnswer(TripDataSelect tripDataSelect) {
    // Check if any answer is correct in the selection array
    for (int number in tripDataController.getStepItem(tripDataSelect: tripDataSelect).correctSelection) {
      if (tripStateController.getCurrentAnswer() == number) {
        return true;
      }
    }
    return false;
  }
}

/// Helper function
///
Axis getAxisLayout() {
  // total height minus height of top image minus height of bottom navigation
  var availableHeight = Get.height -
      (Get.width * Constants.defaultImageRatio) -
      80; // TODO: programatically find height of the navigation
  // print('availableHeight = ' + availableHeight.toString() + ', screen width = ' + Get.width.toString());
  if (availableHeight > Get.width)
    return Axis.vertical;
  else
    return Axis.horizontal;
}

String getAnswerText(
    {required TripStateController tripStateController,
    required TripDataController tripDataController,
    required TripDataSelect tripDataSelect}) {
  // Check if any answer is correct in the selection array
  for (int number in tripDataController.getStepItem(tripDataSelect: tripDataSelect).correctSelection) {
    if (tripStateController.getCurrentAnswer() == number) {
      return tripDataController.getStepItem(tripDataSelect: tripDataSelect).correctAnswer;
    }
  }
  return tripDataController.getStepItem(tripDataSelect: tripDataSelect).incorrectAnswer;
}
