# instant-validation-plugin
Validate APEX page items instantly using this dynamic action plugin. Bind the plugin for example on an "onChange" event of a page item and immediatelly get a feedback if the user input for this page item is valid.

APEX validates page items in a submit process. If the page setting for <b>"Reload on Submit"</b> is set to "Only for Success" an AJAX call is performed prior to the acutal page submit. All validations for all page items are executed. In case of validation errors the error messages will be shown and the page is not submitted. With the standard APEX behavoir for validations there is no way to perform validations for individual page items and for events other then submit. This plugin aims to close the gap. Bind it on any event for a page item and let the validations associated with this page item be executed whenever the event is triggered. In case of errors the item will be highlighted with an error message in the item's error placeholder (standard APEX error rendering) or a custom error handling can be implemented that is triggered whenever the plugin fires the events <code>instant-validation-failure</code> or <code>instant-validation-success</code>.

![instant_validation_demo](https://github.com/user-attachments/assets/b6b384dd-3bc5-41f8-86a6-2e7e63030824)
<br /><br />
Plugin Features
<ul>
  <li>Validate individual page items on request</li>
  <li>Bind execution of validation to any browser event</li>
  <li>Supports both client side (HTML5) and server side (PLSQL) validation</li>
  <li>Supports custom error rendering</li>
  <li>Triggers browser events <code>instant-validation-start</code>, <code>instant-validation-failure</code> and <code>instant-validation-success</code></li>
</ul>
