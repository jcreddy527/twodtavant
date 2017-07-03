({
    initialize: function(component, event) {


        //necessary initializations
        var reportStatusId = component.get("v.reportStatusId");
        var self = this;
        var sectionListToDisplay = null;
        var maxQuestionsOnPage = parseInt(component.get("v.maxQuestionsOnPage"));
        var currentPageAnswerList = null;
        self.displaySpinner(component);

        // get all sequenced questions from record Id
        var sequencedQuestionList = null;
        var isInitialLoad = component.get("v.isInitialLoad");
        var isRelaunch = component.get("v.isRelaunch");
        var query = null;

        // check if the load is initial load and query accordingly
        if (isInitialLoad) {

            if (!isRelaunch) {

                query = "Select r.Questionnaire__r.Id, r.Questionnaire__c,r.Questionnaire__r.Form_Heading__c, r.Name, r.Id," +
                    "r.Questionnaire__r.Max_Question_Count__c,r.Questionnaire__r.Is_Active__c,Status__c, " +
                    "(Select Id, Name,Current_Display_Order__c, Question__c , Question__r.Is_Dependent__c " +
                    "From Sequence_Questions__r where Question__r.Is_Dependent__c=false AND Question__r.Active__c=true " +
                    "AND Question__r.Section__r.Is_Active__c=true AND Report_Status__c='" + reportStatusId + "' ORDER BY " +
                    "Question__r.Section__r.Priority__c,Question__r.Priority__c LIMIT " +
                    maxQuestionsOnPage + ") " + "From Report_Status__c r where r.Id='" +
                    reportStatusId + "'";

            } else {

                query = "Select r.Questionnaire__r.Id, r.Questionnaire__c,r.Questionnaire__r.Form_Heading__c, r.Name, r.Id,r.Next_Page_Id_Marks__c," +
                    "r.Questionnaire__r.Max_Question_Count__c,r.Questionnaire__r.Is_Active__c,Status__c, " +
                    "(Select Id, Name,Current_Display_Order__c, Question__c , Question__r.Is_Dependent__c,Question__r.Section__r.Priority__c " +
                    "From Sequence_Questions__r where Question__r.Active__c=true AND Current_Display_Order__c " +
                    "NOT IN(-1,-2) " +
                    "AND Question__r.Section__r.Is_Active__c=true AND Report_Status__c='" + reportStatusId + "') From Report_Status__c r where r.Id='" +
                    reportStatusId + "'";

            }

            console.log(query);

        } else {

            var sqMarkList = JSON.parse(JSON.stringify(component.get("v.currentSQMarkList")));
            var toQuestionIdList = sqMarkList.map(function(a) {
                if(a["selectedExpectedAnswer"]!==null && a["selectedExpectedAnswer"]!==undefined){
                	return a["selectedExpectedAnswer"]["To_Question__c"];
                }
            });

            var stringifiedIdList = self.stringifyIdList(toQuestionIdList);

            query = "Select r.Questionnaire__r.Id, r.Questionnaire__c,r.Questionnaire__r.Form_Heading__c, r.Name, r.Id," +
                "r.Questionnaire__r.Max_Question_Count__c,r.Questionnaire__r.Is_Active__c,Status__c, " +
                "(Select Id, Name,Current_Display_Order__c, Question__c , Question__r.Is_Dependent__c " +
                "From Sequence_Questions__r where (Question__r.Active__c=true AND Current_Display_Order__c " +
                "NOT IN(-1,-2)) AND ( (Question__r.Is_Dependent__c=false) OR (Question__r.Id IN (" + stringifiedIdList + "))) " +
                "AND Question__r.Section__r.Is_Active__c=true AND Report_Status__c='" + reportStatusId + "' ORDER BY " +
                "Question__r.Section__r.Priority__c,Question__r.Priority__c " +
                "LIMIT " + maxQuestionsOnPage + ") From Report_Status__c r where r.Id='" + reportStatusId + "'";

            // reset the sqMark list
            component.set("v.currentSQMarkList", []);



        }

        // read for the corrosponding sequence questions via report status id
        self.readRaw(component, event, self, query, function(resultStatusResponse) {

            var resultStatus = resultStatusResponse.sObjectList;
            var questionnaire = null;
            // case when this read operation is successful
            if (resultStatus != null && resultStatus != undefined && resultStatus.length != 0) {

                resultStatus = resultStatus[0];
                questionnaire = resultStatus["Questionnaire__r"];


                if (resultStatus["Status__c"] != 'Completed') {

                    if (questionnaire != null && questionnaire != undefined && questionnaire["Is_Active__c"]) {
                        maxQuestionsOnPage = questionnaire["Max_Question_Count__c"];
                        component.set("v.maxQuestionsOnPage", maxQuestionsOnPage);
                        component.set("v.questionnaireHeading", questionnaire["Form_Heading__c"]);

                        // get all the question Ids
                        var questionIdList = [];

                        // get all sequenced questions
                        sequencedQuestionList = resultStatus["Sequence_Questions__r"];

                        if (component.get("v.isRelaunch")) {

                            var Idtext = resultStatus.Next_Page_Id_Marks__c;
                            var IdList = Idtext.split(",");

                            sequencedQuestionList = sequencedQuestionList.filter(function(a) {
                                console.log(IdList.indexOf("'" + a["Question__c"] + "'"));
                                if ((IdList.indexOf("'" + a["Question__c"] + "'") > -1) || (!a['Question__r']['Is_Dependent__c'])) {
                                    return a;
                                }
                            });

                            //sort by section
                            sequencedQuestionList = sequencedQuestionList.sort(function(a, b) {
                                return (a['Question__r']['Section__r']['Priority__c'] -
                                    b['Question__r']['Section__r']['Priority__c']);
                            });

                            //sort by self Priority
                            sequencedQuestionList = sequencedQuestionList.sort(function(a, b) {
                                return (a['Question__r']['Priority__c'] -
                                    b['Question__r']['Priority__c']);
                            });

                            // proceed without relaunch status
                            //component.set("v.isRelaunch", false);

                        }



                        if (sequencedQuestionList != undefined && sequencedQuestionList != null &&
                            sequencedQuestionList.length != 0) {

                            // get question id list from sequence question list
                            questionIdList = sequencedQuestionList.map(function(a) {
                                return a["Question__c"];
                            });

                            // check if the load is initial load and query accordingly
                            query = "Select q.Section__r.Section_Heading_Value__c,q.Priority__c,q.Is_Mandatory__c, q.Section__r.Priority__c," +
                                "q.Is_Dependent__c,q.Section__r.Is_Active__c,q.Section__r.Name, q.Section__r.Questionnaire__c, q.Section__c," +
                                "q.Question_Value__c,q.Type_of_Question__c, q.Id,(Select Id, Name, Expected_Answer_Value__c, To_Question__c " +
                                "From Expected_Answers__r) From Question__c q where Id In (" + self.stringifyIdList(questionIdList) + ")";

                            // read for questions object
                            self.readRaw(component, event, self, query, function(questionResponse) {

                                var questionRelatedToSelectedQuestionList = questionResponse.sObjectList;

                                // if question object read is successful
                                if (questionRelatedToSelectedQuestionList != null && questionRelatedToSelectedQuestionList !=
                                    undefined && questionRelatedToSelectedQuestionList.length != 0) {

                                    // map question objects with respective sequence question objects
                                    for (var i = 0; i < sequencedQuestionList.length; i++) {
                                        for (var j = 0; j < questionRelatedToSelectedQuestionList.length; j++) {
                                            if (questionRelatedToSelectedQuestionList[j] != null &&
                                                questionRelatedToSelectedQuestionList[j] != undefined) {
                                                if (questionRelatedToSelectedQuestionList[j]["Id"] ==
                                                    sequencedQuestionList[i]["Question__c"]) {
                                                    sequencedQuestionList[i]["Question__r"] =
                                                        questionRelatedToSelectedQuestionList[j];
                                                    break;
                                                }
                                            }
                                        }
                                    }

                                    // get displayable sections
                                    var sectionListToDisplay = self.makeSectionGroups(sequencedQuestionList);

                                    if (sectionListToDisplay.length != 0) {
                                        component.set("v.sectionListToDisplay", sectionListToDisplay);
                                        self.hideSpinner(component);
                                    }

                                } else {

                                    self.hideSpinner(component);
                                    // no questions related to sequence questions found error message
                                    console.log("no questions related to sequence questions found");
                                    console.log(questionResponse);

                                }

                            });


                        } else {

                            self.hideSpinner(component);

                            // message for no sequence question found for this report status
                            if (!isInitialLoad) {

                                component.set('v.currentReportStatus', 'Completed');
                                var alertboxContent = {
                                    message: 'Thanks for the response...Kindly press okay to complete the response...',
                                    heading: 'Completed',
                                    class: 'slds-theme--success',
                                    callableFunction: component.getReference('c.updateReportingStatus'),
                                    buttonHeading: "Okay"
                                };
                                self.showAlert(component, alertboxContent);

                            } else {


                              if(component.get("v.isRelaunch")){

                                // if relaunch, then show the thanks message as user had drafted the questionnaite on last page
                                component.set('v.currentReportStatus', 'Completed');
                                var alertboxContent = {
                                    message: 'Thanks for the response...Kindly press okay to complete the response...',
                                    heading: 'Completed',
                                    class: 'slds-theme--success',
                                    callableFunction: component.getReference('c.updateReportingStatus'),
                                    buttonHeading: "Okay"
                                };
                                // set the relaunch as false
                                component.set("v.isRelaunch",false);
                                self.showAlert(component, alertboxContent);

                              }else{
                                console.log("Sorry no sequence question found or some error in initialize()");
                                console.log(resultStatusResponse);
                              }

                            }

                        }

                    } else {

                        self.hideSpinner(component);
                        // message for No active questionnaire found..
                        console.log("No active questionnaire found..");
                        var alertboxContent = {
                            message: 'No active questionnaire found...',
                            heading: 'Cannot move further',
                            class: 'slds-theme--shade',
                            callableFunction: component.getReference('c.redirectToTarget'),
                            buttonHeading: "Ok"
                        };
                        self.showAlert(component, alertboxContent);


                    }
                } else {

                    self.hideSpinner(component);
                    // message for report status already completed
                    console.log("The questionnaire for this record is completed..");
                    var alertboxContent = {
                        message: 'Questionnaire already completed on this record...',
                        heading: 'Cannot move further',
                        class: 'slds-theme--shade',
                        callableFunction: component.getReference('c.redirectToTarget'),
                        buttonHeading: "Ok"
                    };
                    self.showAlert(component, alertboxContent);
                }

            } else {

                self.hideSpinner(component);
                // message for no report status record
                    console.log("Sorry no report status record found or error occured in initialize()");
                    console.log(resultStatusResponse);

            }

        });

    },

    next: function(component, event, forSaveAsDraft) {

        //safe initialzation
        var self = this;

        var validated = self.validateMandatory(component, event);

        if (validated) {

            // show the spinner
            self.displaySpinner(component);

            var currentPageAnswerList = component.get("v.currentPageAnswerList");

            if (currentPageAnswerList != null && currentPageAnswerList != undefined &&
                currentPageAnswerList.length != 0) {

                currentPageAnswerList = JSON.parse(JSON.stringify(component.get("v.currentPageAnswerList")));

                // insert the current page answers
                self.insertRaw(component, event, self, currentPageAnswerList, function(answerResponse) {

                    // case when answers are successfully inserted
                    if (answerResponse["errorArrays"] == null || answerResponse["errorArrays"] == undefined ||
                        answerResponse["errorArrays"].length == 0) {

                        // get Id's for all the sequenced questions for which answers are inserted
                        var answeredSQIdList = component.get("v.currentPageAnsweredSQIdList");

                        var sequenceQuestionListToUpdate = []; // empty array which will contain all updatable
                        //sequence questions list with
                        //new priorities

                        var answeredUnAnsweredSequencedQuestionList = self.getAnsweredUnAnsweredSQEmptyObjects(component, answeredSQIdList);
                        var dependentSQList = [];

                        var currentMarkList = JSON.parse(JSON.stringify(component.get("v.currentSQMarkList")));

                        // fill dependentSQList
                        var selectedExpectedAnswer = null;
                        var notSelectedExpectedAnswerList = [];

                        // fill updatable sequence questions priorities such as
                        // -1 for disabled sequence questions (non mandatory and non-selected to-dependent-Questions)
                        // -2 for answered sequence questions
                        // priority of parent from sequence question for to sequence question
                        for (var i = 0; i < currentMarkList.length; i++) {

                            selectedExpectedAnswer = currentMarkList[i]["selectedExpectedAnswer"];
                            notSelectedExpectedAnswerList = currentMarkList[i]["rejectedExpectedAnswerList"];

                            // fill not selectedExpectedAnswerList with non mandatory unfilled toSQList
                            for (var i = 0; i < answeredUnAnsweredSequencedQuestionList.length; i++) {
                                if (answeredUnAnsweredSequencedQuestionList[i]["Current_Display_Order__c"] == -1) {
                                    notSelectedExpectedAnswerList = notSelectedExpectedAnswerList.concat(
                                        answeredUnAnsweredSequencedQuestionList[i]['Question__r']['Expected_Answers__r']);
                                }
                            }
                            notSelectedExpectedAnswerList = JSON.parse(JSON.stringify(notSelectedExpectedAnswerList));

                            // fill dependentSQList with unselected toSQList
                            for (var j = 0; j < notSelectedExpectedAnswerList.length; j++) {

                                if (notSelectedExpectedAnswerList[j] != null &&
                                    notSelectedExpectedAnswerList[j] != undefined &&
                                    notSelectedExpectedAnswerList[j]["To_Question__c"] != null &&
                                    notSelectedExpectedAnswerList[j]["To_Question__c"] != undefined) {
                                    var dependentToSQUnsuccessful = {
                                        Id: null,
                                        Question__c: notSelectedExpectedAnswerList[j]["To_Question__c"],
                                        Current_Display_Order__c: -1
                                    };

                                    //only push if it is not in selected to question variable
                                    if (dependentToSQUnsuccessful["Question__c"] !=
                                        selectedExpectedAnswer["To_Question__c"]) {
                                        dependentSQList.push(dependentToSQUnsuccessful);
                                    }

                                }

                            }




                            // fill dependentSQList with selected toSQList
                            if (selectedExpectedAnswer["To_Question__c"] != null &&
                                selectedExpectedAnswer["To_Question__c"] != undefined) {
                                var dependentToSQSuccessful = {
                                    Id: null,
                                    Question__c: selectedExpectedAnswer["To_Question__c"],
                                    Current_Display_Order__c: 0
                                };

                                dependentSQList.push(dependentToSQSuccessful);

                            }

                        };

                        // get dependentSQ Ids from backend
                        self.getDependentSQs(component, event, dependentSQList, function(response) {

                            // if we have some dependent sequence questions to show in next page
                            if (response != -1) {
                                var dependentSequenceQuestions = response;

                                // fill priority of successful dependent question
                                if (dependentSequenceQuestions.length != 0) {

                                    for (var i = 0; i < dependentSequenceQuestions.length; i++) {

                                        if (dependentSequenceQuestions[i]["Current_Display_Order__c"] == 0) {

                                            var qId = dependentSequenceQuestions[i]["Question__c"];
                                            var currentMarkForQid = currentMarkList.filter(function(a) {

                                                return (a["selectedExpectedAnswer"]["To_Question__c"] == qId);

                                            });

                                            if (currentMarkForQid.length != 0) {
                                                dependentSequenceQuestions[i]["Current_Display_Order__c"] =
                                                    currentMarkForQid[0]["sequenceQpriority"];
                                            }
                                        }
                                    }

                                }

                                sequenceQuestionListToUpdate =
                                    sequenceQuestionListToUpdate.concat(answeredUnAnsweredSequencedQuestionList).concat(
                                        dependentSequenceQuestions);
                            } else {

                                // if we do not have any dependent sq to update for next page
                                sequenceQuestionListToUpdate =
                                    sequenceQuestionListToUpdate.concat(answeredUnAnsweredSequencedQuestionList);
                            }

                            //update all sequence question list
                            self.updateRaw(component, event, self, sequenceQuestionListToUpdate, function(sqResponse) {

                                var sobjectList = sqResponse["sobjectsAndStatus"];
                                if (sobjectList != null && sobjectList != undefined && sobjectList.length != 0) {

                                    // reinitialise the page variables other than sq mark as
                                    component.set("v.isInitialLoad", false);
                                    component.set("v.currentPageAnswerList", []);
                                    component.set("v.sectionListToDisplay", []);
                                    component.set("v.currentPageAnsweredSQIdList", []);
                                    component.set("v.isRelaunch", false);

                                    if (!forSaveAsDraft) {
                                        //call initialize method again
                                        self.initialize(component, event);
                                    } else {

                                        //set the report status as in progress
                                        var sqMarkList = JSON.parse(JSON.stringify(component.get("v.currentSQMarkList")));
                                        var toQuestionIdList = sqMarkList.map(function(a) {
                                            return a["selectedExpectedAnswer"]["To_Question__c"];
                                        });
                                        var stringifiedIdList = self.stringifyIdList(toQuestionIdList);
                                        // update report status object
                                        self.updateReportingStatus(component, event, stringifiedIdList);

                                    }

                                } else {

                                    // show error
                                    console.log("All sequence questions cannot be updated, " +
                                        +"kindly see the response in next()");
                                    console.log(sqResponse);

                                }

                            });

                        });

                    } else {

                        // some error occured while insertion of answer error message
                        console.log("Some error occured while insertion of answer,check the response below");
                        console.log(answerResponse);

                    }

                });

            } else {

                this.hideSpinner(component);

                // reinitialise the page variables other than sq mark as
                component.set("v.isInitialLoad", false);
                component.set("v.currentPageAnswerList", []);
                component.set("v.sectionListToDisplay", []);
                component.set("v.currentPageAnsweredSQIdList", []);
                component.set("v.isRelaunch", false);

                if (!forSaveAsDraft) {
                    //call initialize method again
                    self.initialize(component, event);
                } else {
                    //set the report status as in progress
                    var sqMarkList = JSON.parse(JSON.stringify(component.get("v.currentSQMarkList")));
                    var toQuestionIdList = sqMarkList.map(function(a) {
                        return a["selectedExpectedAnswer"]["To_Question__c"];
                    });
                    var stringifiedIdList = self.stringifyIdList(toQuestionIdList);
                    self.updateReportingStatus(component, event, stringifiedIdList);

                }

            }


        } else {

            var alertboxContent = {
                message: 'All mandatory questions are not filled..',
                heading: 'Incomplete form',
                class: 'slds-theme--error',
                callableFunction: component.getReference('c.closeAlert'),
                buttonHeading: 'Close'
            };
            self.showAlert(component, alertboxContent);

        }

    },

    stringifyIdList: function(IdArray) {

        var returnableList = [];
        var returnable = null;
        if (IdArray != null && IdArray != undefined) {
            for (var i = 0; i < IdArray.length; i++) {
                if (IdArray[i] != null && IdArray[i] != undefined) {
                    var insertable = "'" + IdArray[i] + "'";
                    returnableList.push(insertable);
                }
            }
        }
        returnable = returnableList.toString();
        if (returnable == "") {
            console.log("Id list cannot be listified or empty");
            returnable = "''";
        }
        return returnable;
    },

    sortSections: function(sectionList) {

        var returnablesortedSectionList = null;
        var tempSectionList = JSON.parse(JSON.stringify(sectionList));
        returnablesortedSectionList = tempSectionList.sort(function(sectionA, sectionB) {
            if (sectionA["sectionPriority"] < sectionB["sectionPriority"]) {
                return -1;
            }
            if (sectionA["sectionPriority"] > sectionB["sectionPriority"]) {
                return 1;
            }
            return 0;
        });

        return returnablesortedSectionList;

    },

    makeSectionGroups: function(sequencedQuestionList) {

        var sectionNameSet = [];
        var sectionListToDisplay = [];

        for (var i = 0; i < sequencedQuestionList.length; i++) {
            var sectionName = sequencedQuestionList[i]["Question__r"]["Section__r"]["Name"];
            if (sectionNameSet.indexOf(sectionName) == -1) {
                sectionNameSet.push(sectionName);
            }
        }


        for (var i = 0; i < sectionNameSet.length; i++) {

            var section = {
                sectionName: sectionNameSet[i],
                sectionPriority: 0,
                sectionHeading: null,
                questionList: []
            };

            for (var j = 0; j < sequencedQuestionList.length; j++) {

                var sectionName = sequencedQuestionList[j]["Question__r"]["Section__r"]["Name"];
                if (sectionName == sectionNameSet[i]) {
                    section["questionList"].push(sequencedQuestionList[j]);

                    if (section["sectionPriority"] == 0) {
                        section["sectionPriority"] = sequencedQuestionList[j]["Question__r"]
                            ["Section__r"]["Priority__c"];
                    }
                    if (section["sectionHeading"] == null) {
                        section["sectionHeading"] = sequencedQuestionList[j]["Question__r"]
                            ["Section__r"]["Section_Heading_Value__c"];
                    }
                }

            }

            sectionListToDisplay.push(section);

        }
        return sectionListToDisplay;
    },

    markAnswer: function(component, event) {

        // essential initializations
        var sequenceQuestion = JSON.parse(JSON.stringify(event.getSource().get("v.labelClass")));
        var sequenceQuestionPriority = sequenceQuestion["Current_Display_Order__c"];
        var questionId = sequenceQuestion["Question__c"];
        var sequenceQuestionId = sequenceQuestion["Id"];
        var currentPageAnswerList = JSON.parse(JSON.stringify(component.get("v.currentPageAnswerList")));
        var questionType = sequenceQuestion["Question__r"]["Type_of_Question__c"];
        var answeredSqList = component.get("v.currentPageAnsweredSQIdList");

        // mark answer for single select radio button
        if (questionType == 'Single select') {

            var expectedAnswerList = sequenceQuestion["Question__r"]["Expected_Answers__r"];
            var expectedAnswerId = event.getSource().get("v.text");

            // fill array of markers of single select question
            var currentSQMarkList = component.get("v.currentSQMarkList");
            var choosenExpectedAnswer = expectedAnswerList.filter(function(a) {
                return (a["Id"] == expectedAnswerId);
            });
            if (choosenExpectedAnswer.length != 0) {
                choosenExpectedAnswer = choosenExpectedAnswer[0];
            }

            //fill list of rejected expected answers
            var rejectedExpectedAnswerList = expectedAnswerList.filter(function(a) {
                return (a["Id"] != expectedAnswerId);
            });

            // update the question mark for single select radio question
            var existingSQMark = currentSQMarkList.filter(function(a) {
                return (a["questionId"] == questionId);
            });

            if (existingSQMark.length != 0) {
                currentSQMarkList = currentSQMarkList.filter(function(a) {
                    return (a["questionId"] != questionId);
                });
            }

            var selectedQuestionMark = {
                questionId: questionId,
                sequenceQId: sequenceQuestionId,
                selectedExpectedAnswer: choosenExpectedAnswer,
                rejectedExpectedAnswerList: rejectedExpectedAnswerList,
                sequenceQpriority: sequenceQuestionPriority
            };

            currentSQMarkList.push(selectedQuestionMark);
            component.set("v.currentSQMarkList", currentSQMarkList);

            // fill answer array of current page with latest answer of this sequenced question

            // remove old answer if exist
            currentPageAnswerList = currentPageAnswerList.filter(function(a) {
                return (a["Question__c"] != questionId);
            });

            var answer = {
                sobjectType: "Answer__c",
                Question__c: questionId,
                Expected_Answer__c: expectedAnswerId,
                Related_Record_Id__c: component.get("v.recordId"),
                Report_Status__c: component.get("v.reportStatusId")
            };
            currentPageAnswerList.push(answer);
            component.set("v.currentPageAnswerList", currentPageAnswerList);

            // fill array of answered sq Id
            var answeredSQ = answeredSqList.filter(function(a) {
                return (a == sequenceQuestionId);
            });
            if (answeredSQ.length == 0) {
                answeredSqList.push(sequenceQuestionId);
                component.set("v.currentPageAnsweredSQIdList", answeredSqList);
            }


        } else if (questionType == 'Multiple select') {
            // mark answer for multi select checkbox type question

            //essential initializations
            var isSelected = event.getSource().get("v.value");
            var expectedAnswerId = event.getSource().get("v.text");

            // if checked case
            if (isSelected == true) {

                // insert new answer in the answer list
                var answer = {
                    sobjectType: "Answer__c",
                    Question__c: questionId,
                    Expected_Answer__c: expectedAnswerId,
                    Related_Record_Id__c: component.get("v.recordId"),
                    Report_Status__c: component.get("v.reportStatusId")
                };
                currentPageAnswerList.push(answer);
                component.set("v.currentPageAnswerList", currentPageAnswerList);

                // fill array of answered sq Id
                var answeredSQId = answeredSqList.filter(function(a) {
                    return (a == sequenceQuestionId);
                });
                if (answeredSQId.length == 0) {
                    answeredSqList.push(sequenceQuestionId);
                    component.set("v.currentPageAnsweredSQIdList", answeredSqList);
                }

            } else {
                // if unchecked case

                // remove the answer related to this expected answer from answer array
                currentPageAnswerList = currentPageAnswerList.filter(function(a) {
                    return (a["Expected_Answer__c"] != expectedAnswerId);
                });

                component.set("v.currentPageAnswerList", currentPageAnswerList);
                currentPageAnswerList = JSON.parse(JSON.stringify(component.get("v.currentPageAnswerList")));

                // find that is there any expected answer existing to this sq that is filled in answer array
                //and remove it
                var answerList = currentPageAnswerList.filter(function(a) {
                    return (a["Question__c"] == questionId);
                });
                if (answerList.length == 0) {
                    answeredSqList = answeredSqList.filter(function(a) {
                        return (a != sequenceQuestionId);
                    });
                    component.set("v.currentPageAnsweredSQIdList", answeredSqList);

                }

            }

        } else if (questionType == 'Text') {

            // for text type answers

            // get current answer value
            var currentAnswerValue = event.getSource().get("v.value");

            // if current answer value is empty, remove answer from answer array if exist
            if (currentAnswerValue == '' || currentAnswerValue == null || currentAnswerValue == undefined) {

                //remove answer from answer list if exist
                currentPageAnswerList = currentPageAnswerList.filter(function(a) {
                    return (a["Question__c"] != questionId);
                });
                component.set("v.currentPageAnswerList", currentPageAnswerList);

                // remove from answered sq id list
                answeredSqList = answeredSqList.filter(function(a) {
                    return (a != sequenceQuestionId);
                });
                component.set("v.currentPageAnsweredSQIdList", answeredSqList);

            } else {

                // initialize new answer object
                var answer = {
                    sobjectType: "Answer__c",
                    Question__c: questionId,
                    Answer_Text__c: currentAnswerValue,
                    Related_Record_Id__c: component.get("v.recordId"),
                    Report_Status__c: component.get("v.reportStatusId")
                };

                //remove old answer if exist
                currentPageAnswerList = currentPageAnswerList.filter(function(a) {
                    return (a["Question__c"] != questionId);
                });

                //insert present answer
                currentPageAnswerList.push(answer);
                component.set("v.currentPageAnswerList", currentPageAnswerList);

                // add into answered sq Id list
                var answeredSQId = answeredSqList.filter(function(a) {
                    return (a == sequenceQuestionId);
                });
                if (answeredSQId.length == 0) {
                    answeredSqList.push(sequenceQuestionId);
                    component.set("v.currentPageAnsweredSQIdList", answeredSqList);
                }

            }

        }

    },

    getSerialQuestionList: function(sectionList, maxCount) {

        var count = 0;
        var tempSectionList = JSON.parse(JSON.stringify(sectionList));
        var returnableQuestionList = [];
        var isFilled = false;


        for (var i = 0; i < tempSectionList.length; i++) {

            for (var j = 0; j < tempSectionList[i]["questionList"].length; j++) {

                if (count < maxCount) {
                    var sqQuestion = tempSectionList[i]["questionList"][j];
                    returnableQuestionList.push(sqQuestion);
                    count++;
                } else {
                    isFilled = true;
                    break;
                }

            }
            if (isFilled == true) {
                break;
            }
        }

        return returnableQuestionList;

    },

    getAnsweredUnAnsweredSQEmptyObjects: function(component, IdList) {

        var sequencedQuestionUpdatableList = [];

        // get all sequence questions which are not answered
        var currentPageSections = component.get("v.sectionListToDisplay");
        var sqList = [];

        for (var i = 0; i < currentPageSections.length; i++) {
            if (currentPageSections[i]["questionList"] != undefined && currentPageSections[i]["questionList"] != null &&
                currentPageSections[i]["questionList"].length != 0) {
                sqList = sqList.concat(currentPageSections[i]["questionList"]);
            }
        }

        var unAnsweredSQList = sqList.filter(function(a) {
            return (IdList.indexOf(a['Id']) < 0);
        });

        // for answered sequence questions
        for (var i = 0; i < IdList.length; i++) {
            var sequencedQuestion = {
                Id: IdList[i],
                Current_Display_Order__c: -2
            };
            sequencedQuestionUpdatableList.push(sequencedQuestion);
        }

        // for unanswered sq list
        for (var i = 0; i < unAnsweredSQList.length; i++) {
            unAnsweredSQList[i]["Current_Display_Order__c"] = -1;
            sequencedQuestionUpdatableList.push(unAnsweredSQList[i]);
        }
        return sequencedQuestionUpdatableList;

    },

    displaySpinner: function(component) {
        component.set("v.displaySpinner", true);
    },

    hideSpinner: function(component) {
        component.set("v.displaySpinner", false);
    },

    getDependentSQs: function(component, event, sqEmptyObjectList, callback) {

        // safe initialization
        var self = this;

        // get all question Id list from sequenced question empty list to be changed
        var questionIdList = sqEmptyObjectList.map(function(a) {
            return a["Question__c"]
        });

        var returnable = null;
        var reportStatusId = component.get("v.reportStatusId");
        var listifiedIdString = this.stringifyIdList(questionIdList);

        // case when question id list is listified successfully
        if (listifiedIdString != "''") {

            var query = "Select Id,Current_Display_Order__c,Question__c from Sequence_Question__c where " +
                "Report_Status__c='" + reportStatusId + "' AND Question__c " +
                "IN (" + listifiedIdString + ")";

            // read operation for getting Id's of 'to sequence questions' for which 'to question Id' we have
            self.readRaw(component, event, self, query, function(response) {

                var sequenceQuestionsList = response.sObjectList;

                // case if read is successful
                if (sequenceQuestionsList != undefined &&
                    sequenceQuestionsList != null && sequenceQuestionsList.length != 0) {

                    // fill empty to sequence question list
                    for (var i = 0; i < sqEmptyObjectList.length; i++) {

                        var questionId = sqEmptyObjectList[i]["Question__c"];
                        var selectedSQ = sequenceQuestionsList.filter(function(a) {
                            return (a["Question__c"] == questionId);
                        });
                        if (selectedSQ.length != 0) {
                            sqEmptyObjectList[i]["Id"] = selectedSQ[0]["Id"];
                        }
                    }
                    callback(sqEmptyObjectList);
                } else {
                    console.log("read for Id's of to sequence questions failed in getDependentSQs()");
                    console.log(response);
                }
            });


        } else {

            // Id list cannot be listified or empty
            console.log("question Id list in getDependentSQs() is empty or cannot be listified");
            callback(-1);

        }

    },

    showAlert: function(component, alertboxContent) {

        // create dynamic alert box with some initializations
        var self = this;
        var test;
        $A.createComponent(
            "c:AlertboxCmp", {
                message: alertboxContent.message,
                heading: alertboxContent.heading,
                class: alertboxContent.class,
                onOkay: alertboxContent.callableFunction,
                buttonHeading: alertboxContent.buttonHeading
            },
            function(alertbox) {

                if (alertbox!==undefined && alertbox!==null && alertbox.isValid()) {
                    var body = [];
                    body.push(alertbox);
                    if (!alertbox.isInstanceOf("c:AlertboxCmp")) {
                        component.set("v.body", []);
                    } else {
                        component.set("v.body", body);
                    }

                }
            }

        );

    },

    updateReportingStatus: function(component, event, idListString) {

        var isCompletedOnline = false;

        if(component.get('v.currentReportStatus')==='Completed'){
          isCompletedOnline = true;
        }

        var self = this;
        var reportStatus = {
            Id: component.get('v.reportStatusId'),
            Status__c: component.get('v.currentReportStatus'),
            Next_Page_Id_Marks__c: idListString,
            Is_Completed_Online__c : isCompletedOnline
        };

        this.updateRaw(component, event, this, reportStatus, function(reportStatusUpdateResponse) {

            var sObjectAndStatus = reportStatusUpdateResponse.sobjectsAndStatus;
            if (sObjectAndStatus != undefined && sObjectAndStatus != null && sObjectAndStatus.length != 0) {

                // redirect to record
                self.redirectToTarget(component, event);

            } else {

                // message for error in updation of report status object
                console.log('Report status object cannot be updated.. error in updateReportingStatus()');
                console.log(reportStatusUpdateResponse);

            }

        });

    },

    redirectToTarget: function(component, event) {
		
        var sitePrefix = component.get('v.sitePrefix');	
        
        if ((typeof sforce != 'undefined') && (sforce != null)) {
            // Salesforce1 navigation
            sforce.one.navigateToSObject(component.get("v.recordId"));
        } else {
            
            if(sitePrefix===''){
            	window.location.href = '/' + component.get("v.recordId");    
            }else{
                window.location.href = sitePrefix + '/' + component.get("v.recordId");    
            }
            
        }

    },

    reset: function(component, event) {

        var self = this;
        var reportStatusId = component.get('v.reportStatusId');
        var alertboxContent = {
            message: 'Resetting the questionnaire...',
            heading: 'Wait',
            class: 'slds-theme--info',
            buttonHeading: null
        };
        self.showAlert(component, alertboxContent);

        // query all sequence questions and answers of this report status
        var query = "select Name,Id,(select Id,Question__r.Priority__c from Sequence_Questions__r where Report_Status__c='" + reportStatusId + "')," +
            "(select Id from Answers__r where Report_Status__c='" + reportStatusId + "') from Report_Status__c " +
            "where Id='" + reportStatusId + "'";

        self.readRaw(component, event, self, query, function(reportStatusResponse) {

            var reportStatus = reportStatusResponse.sObjectList;

            if (reportStatus != undefined && reportStatus != null && reportStatus.length != 0) {

                // get all the answers and sequence question related to the report status object
                var answerList = reportStatus[0]["Answers__r"];
                var sqList = reportStatus[0]["Sequence_Questions__r"];

                // delete answers related to this report status
                if (answerList != undefined) {

                    self.deleteRaw(component, event, self, answerList, function(answerDeleteResponse) {
                        var statusArray = answerDeleteResponse["statusArray"];

                        // update  Current Display Order of sequence questions related to this report status
                        if (statusArray != null && statusArray != undefined && statusArray.length != 0) {

                            var updatedSQList = sqList.map(function(a) {
                                var updatedA = {};
                                updatedA["Id"] = a["Id"];
                                updatedA["Current_Display_Order__c"] = a["Question__r"]["Priority__c"];
                                return updatedA;
                            });

                            self.updateRaw(component, event, self, updatedSQList, function(updateSqResponse) {

                                var sobjectsAndStatus = updateSqResponse["sobjectsAndStatus"];
                                if (sobjectsAndStatus != null && sobjectsAndStatus != undefined &&
                                    sobjectsAndStatus.length != 0) {

                                    // update report status to draft
                                    component.set('v.currentReportStatus', 'Draft');
                                    self.updateReportingStatus(component, event, '');
                                    //nothing after this line

                                } else {

                                    // message for error in updation of priorities of sequence questions
                                    console.log("Error in updation of sequence questions");
                                    console.log(updateSqResponse);

                                }

                            });

                        } else {

                            // message for error in deletion of answers
                            console.log("Error in deletion of answers");
                            console.log(answerDeleteResponse);

                        }

                    });

                } else {

                    // update only sequence questions iif answers are not present
                    var updatedSQList = sqList.map(function(a) {
                        var updatedA = {};
                        updatedA["Id"] = a["Id"];
                        updatedA["Current_Display_Order__c"] = a["Question__r"]["Priority__c"];
                        return updatedA;
                    });

                    self.updateRaw(component, event, self, updatedSQList, function(updateSqResponse) {

                        var sobjectsAndStatus = updateSqResponse["sobjectsAndStatus"];
                        if (sobjectsAndStatus != null && sobjectsAndStatus != undefined && sobjectsAndStatus.length != 0) {

                            // update report status to draft
                            component.set('v.currentReportStatus', 'Draft');
                            self.updateReportingStatus(component, event, null);

                        } else {

                            // message for error in updation of priorities of sequence questions
                            console.log("Error in updation of sequence questions");
                            console.log(updateSqResponse);

                        }
                    });

                }

            }

        });
    },

    saveAsDraft: function(component, event) {

        component.set("v.currentReportStatus", 'In Progress');
        this.next(component, event, true);
        // nothing should come after this line

    },

    validateMandatory: function(component, event) {

        var currentPageAnswerList = JSON.parse(JSON.stringify(component.get("v.currentPageAnswerList")));
        var sectionList = JSON.parse(JSON.stringify(component.get("v.sectionListToDisplay")));
        var currentPageSequenceQuestionList = [];
        var allMandatoryQuestionsAnswered = true;

        for (var i = 0; i < sectionList.length; i++) {
            if (sectionList[i]["questionList"] != null && sectionList[i]["questionList"] != undefined &&
                sectionList[i]["questionList"].length != 0) {
                currentPageSequenceQuestionList =
                    currentPageSequenceQuestionList.concat(sectionList[i]["questionList"]);
            }
        }

        // get Id of mandatory questions
        var mandatoryQuestionIdList = currentPageSequenceQuestionList.map(function(a) {
            if (a["Question__r"]["Is_Mandatory__c"] == true) {
                return a["Question__r"]["Id"];
            }
        });
        mandatoryQuestionIdList = mandatoryQuestionIdList.filter(function(a) {
            return (a != undefined && a != null);
        });

        // for all mandatory questios, find if answer is there in current page answer list.
        for (var i = 0; i < mandatoryQuestionIdList.length; i++) {
            var answerListFormandatoryQuestion = currentPageAnswerList.filter(function(a) {
                return (a["Question__c"] == mandatoryQuestionIdList[i]);
            });

            if (answerListFormandatoryQuestion.length == 0) {
                allMandatoryQuestionsAnswered = false;
                break;
            }

        }

        return allMandatoryQuestionsAnswered;

    }
})