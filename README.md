# instant-validation-plugin
Validate APEX page items instantly using this dynamic action plugin. Bind the plugin for example on an "onChange" event of a page item and immediatelly get a feedback if the user input for this page item is valid.

APEX validates page items in a submit process. If the page setting for <b>"Reload on Submit"</b> is set to "Only for Success" an AJAX call is performed prior to the acutal page submit. All validations for all page items are executed. In case of validation errors the error messages will be shown and the page is not submitted. With the standard APEX behavoir for validations there is no way to perform validations for individual page items and for events other then submit. This plugin aims to close the gap. Bind it on any event for a page item and let the validations associated with this page item be executed immediatelly. In case of errors the item will be highlighted with an error message in the item's error placeholder.

![instant_validation_demo](https://github.com/user-attachments/assets/b6b384dd-3bc5-41f8-86a6-2e7e63030824)
