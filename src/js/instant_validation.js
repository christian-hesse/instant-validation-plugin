function instant_validation( obj ) {

    const errorClass   = 'apex-page-item-error';
    const eventStart   = 'instant-validation-start';
    const eventSuccess = 'instant-validation-success';
    const eventFailure = 'instant-validation-failure';
    const eventError   = 'instant-validation-error';

    function getItemsToSubmit( item, additionalItemsToSubmit ) {

        if( additionalItemsToSubmit === null ) {
            return [item];
        } 

        if( additionalItemsToSubmit.trim().length === 0 ) {
            return [item];
        }
          
        return additionalItemsToSubmit.split(',').concat([item]);
    }

    function setError( item, errorMessage ) {

        // We are not using apex.message.showErrors() here
        // since it requires to call apex.message.clearErrors() first.
        // There is currently no way to clear error messages for
        // individual page items.

        item.addClass(errorClass);
        $('#' + item.attr('id') + '_error_placeholder').text(errorMessage);
    }

    function resetError( item ) {

        item.removeClass(errorClass);
        $('#' + item.attr('id') + '_error_placeholder').text('');
    }

    let triggeringItem   = $(obj.triggeringElement),
        triggeringItemId = triggeringItem.attr('id'),
        pluginAttributes = {
                             itemsToSubmit: obj.action.attribute01,
                             showIndicator: obj.action.attribute02,
                             renderError:   obj.action.attribute03
                           },
        itemsToSubmit    = getItemsToSubmit(triggeringItemId, pluginAttributes.itemsToSubmit);

    apex.event.trigger(triggeringItem, eventStart);
    apex.debug('[Instant validation]: validation started for item "' + triggeringItemId + '"');

    // perform client side HTML5 validation
    let item = apex.item(triggeringItemId),
        itemValidity = item.getValidity();

    if( !itemValidity.valid ) {
        apex.debug('[Instant validation]: validation for item "' + triggeringItemId + '" ended with failure');

        let validationErrorMsg = item.getValidationMessage(),
            validationTypeFailed;

        if( itemValidity.patternMismatch ) {
            validationTypeFailed = 'PATTERN_MISMATCH';
        } else if( itemValidity.valueMissing ) {
            validationTypeFailed = 'ITEM_REQUIRED';
        } else if( itemValidity.customError ) {
            validationTypeFailed = 'CUSTOM_ERROR';
        }

        if( pluginAttributes.renderError === 'Y' ) {
            setError(triggeringItem, validationErrorMsg);
        }

        apex.event.trigger(triggeringItem, eventFailure, {
            "validationResult":{
                 "item": triggeringItemId
                ,"validationType": validationTypeFailed
                ,"passed": false
                ,"message": validationErrorMsg
            }
        });
        
        return;
    }

    // perform server-side validation via AJAX call
    let ajaxData = {
            x01: triggeringItemId,
            pageItems: itemsToSubmit 
        },
        ajaxOptions = {
            loadingIndicator: pluginAttributes.showIndicator === 'Y' ? triggeringItem : null, 
            success : function( result ) { 
                          if ( result.validationResult.passed == true) {
                              apex.debug('[Instant validation]: validation for item "' + triggeringItemId + '" ended with success');
                              if( pluginAttributes.renderError === 'Y' ) {
                                  resetError(triggeringItem);
                              }
                              apex.event.trigger(triggeringItem, eventSuccess, result);
                          } 
                          else {
                              apex.debug('[Instant validation]: validation for item "' + triggeringItemId + '" ended with failure');
                              if( pluginAttributes.renderError === 'Y' ) {
                                  setError(triggeringItem, result.validationResult.message);
                              }
                              apex.event.trigger(triggeringItem, eventFailure, result);
                          }
                          
                      },
            error: function(textStatus, errorThrown) { 
                       apex.debug('[Instant validation]: Error: ' + textStatus + '\n' + errorThrown);
                       apex.event.trigger(triggeringItem, eventError);
                   }
        };

    apex.server.plugin(obj.action.ajaxIdentifier, ajaxData, ajaxOptions);	  
}