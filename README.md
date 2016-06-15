# Survey-Template
A template for making surveys

## Creating a new survey
When making a new survey, some things are absolute necessities to change in `PQSReferenceManager`:
• change yourdomain.com to the correct domain for submitting survey data
• Set the defaultShowTitle to a real show name
• defaultShowKey needs to be a valid value
• set the companyKey

Once those are set, you shouldn't need to ever go back to `PQSReferenceManager`
Add the questions to `PQSQuestionList` by following the example questions that are already setup


*Note*: __There's currently a bug that requires there to be 2 headers at the top of all surveys or else the first question is not responsive__ 


## To-Do
• Fix bug that requires two headers to start every survey
• Fix sizing changes on True False Question layouts in PQSQuestion (estimated height)
• Fix Clipping on second question for PQSQuestionTypeTrueFalseConditional2
• Fix appendAndItalicizedText in `PQSQuestion`
• Solve multiple dependencies on questions
• Improve HAI branding (colors and layout)
• Allow interaction with PQSMultipleChoiceQuestion table view
