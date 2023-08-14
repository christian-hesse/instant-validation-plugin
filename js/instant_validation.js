function instant_validation( obj, file_prefix ) {

  const cErrorClass = "apex-page-item-error";

  function getItemsToSubmit( item, additionalItemsToSubmit ) {

      if( additionalItemsToSubmit === null ) {
          return [item];
      } 

      if( additionalItemsToSubmit.trim().length === 0 ) {
          return [item];
      }
          
      return additionalItemsToSubmit.split(',').concat([item]);
  }

  function highlightItem( triggeringItemReference ) {
      triggeringItemReference.addClass(cErrorClass);
  }

  function unhighlightItem( triggeringItemReference ) {
      triggeringItemReference.removeClass(cErrorClass);
  }

  let 
    triggeringElement       = $(obj.triggeringElement), 
    triggeringItemId        = triggeringElement.attr('id'),
    triggeringItemReference = $("#"+triggeringItemId),
    pluginAttributes = {
                         itemsToSubmit:    obj.action.attribute01,
                         errorRendering:   obj.action.attribute02,
                         callbackFunction: obj.action.attribute03
    };

  apex.debug('itemsToSubmit: ' + pluginAttributes.itemsToSubmit);
  apex.debug('errorVisualization: ' + pluginAttributes.errorVisualization);  
  apex.debug('callbackFunction: ' + pluginAttributes.callbackFunction);    
  
  apex.debug('Instant validation: validation has been started for item = '+triggeringItemId);

  let ajaxData = {
        x01: triggeringItemId,
        pageItems: getItemsToSubmit(triggeringItemId, pluginAttributes.itemsToSubmit) 
      },
      ajaxOptions = {
		 loadingIndicator: triggeringItemReference, 
         //loadingIndicatorPosition: "after",
         success : function( result, textStatus, ajaxObj ) { 

                       if ( result.validation_result.passed == true) {

                           apex.debug('Instant validation: validation for item = '+triggeringItemId+' ended with success.');
                           unhighlightItem(triggeringItemReference);
                           $('#'+triggeringItemId+'_error_placeholder').text('');
                       } 
                       else {
                           apex.debug('Instant validation: validation for item = '+triggeringItemId+' ended with failure.');
                           highlightItem(triggeringItemReference);
                           $('#'+triggeringItemId+'_error_placeholder').text(result.validation_result.message);
                           apexError = true;
                       }
         },
         error: function(jqXHR, textStatus, errorThrown) { 
                    alert('Error occured while retrieving AJAX data: '+textStatus+"\n"+errorThrown);
                }
      }; 
   apex.debug('pageItems for ajax call: ' + getItemsToSubmit(triggeringItemId, pluginAttributes.itemsToSubmit).toString() );	  
   apex.server.plugin(obj.action.ajaxIdentifier, ajaxData, ajaxOptions);	  
}
