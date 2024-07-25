prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_210200 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2021.10.15'
,p_release=>'21.2.0'
,p_default_workspace_id=>1594392419203793
,p_default_application_id=>106
,p_default_id_offset=>0
,p_default_owner=>'APEXDEV'
);
end;
/
 
prompt APPLICATION 106 - Instant Item Validation
--
-- Application Export:
--   Application:     106
--   Name:            Instant Item Validation
--   Date and Time:   13:27 Thursday July 25, 2024
--   Exported By:     CHRIS
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 14788259458149065
--   Manifest End
--   Version:         21.2.0
--   Instance ID:     792123624233816
--

begin
  -- replace components
  wwv_flow_api.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/dynamic_action/org_christianhesse_instant_validation
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(14788259458149065)
,p_plugin_type=>'DYNAMIC ACTION'
,p_name=>'ORG.CHRISTIANHESSE.INSTANT_VALIDATION'
,p_display_name=>'Instant Item Validation'
,p_category=>'EXECUTE'
,p_supported_ui_types=>'DESKTOP'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'c_debug_msg_prefix  constant varchar2(30) := ''[INSTANT_VALIDATION_PLUGIN]'';',
'',
'',
'/**',
' * For bracket expressions in regular expression pattern matching',
' * the right bracket "]" and the hyphen have to be escaped.',
' * According to Oracle''s Regular Expression syntax they have to appear',
' * first in the bracket expression.',
' */',
'function escape_bracket_expression(',
'    p_pattern in varchar2',
') return varchar2',
'is',
'    l_escaped_pattern varchar2(32767);',
'begin',
'    l_escaped_pattern := p_pattern;',
'   ',
'    if instr(l_escaped_pattern, '''''''') > 0 then',
'        l_escaped_pattern := '''''''' || replace(l_escaped_pattern, '''''''', '''');',
'    end if;',
'',
'    if instr(l_escaped_pattern, '']'') > 0 then',
'        l_escaped_pattern := '']'' || replace(l_escaped_pattern, '']'', '''');',
'    end if;',
'   ',
'    apex_debug.message(p_message => ''%s Escape Bracket Expression Result = %s'', ',
'                       p0        => c_debug_msg_prefix, ',
'                       p1        => nvl(l_escaped_pattern,''NULL''));',
'',
'    return l_escaped_pattern;',
'  ',
'end escape_bracket_expression;',
'',
'',
'/**',
' * Get the item value from session state',
' */',
'function get_item_value(',
'    p_item_name in varchar2',
') return varchar2',
'is',
'    l_item_value varchar2(32767);',
'begin',
'    l_item_value := v(p_item_name);',
'    apex_debug.message(p_message => ''%s Item Value = %s'', ',
'                       p0        => c_debug_msg_prefix, ',
'                       p1        => nvl(l_item_value,''NULL''));',
'',
'    return l_item_value;',
'end get_item_value;',
'',
'',
'/**',
' * Perform validation for an item''s validation type. Check the condition ',
' * type before validation. This function mimics a call to ',
' * wwv_flow_validation.perform_validation() since it is not part of the ',
' * public APEX API.',
' */',
'function validate_item(',
'    p_validation_type         in varchar2,',
'    p_validation_expression1  in varchar2,',
'    p_validation_expression2  in varchar2,',
'    p_authorization_scheme_id in number,',
'    p_condition_type_code     in varchar2,',
'    p_condition_expression1   in varchar2,',
'    p_condition_expression2   in varchar2',
') return boolean',
'is',
'    l_validation_type        varchar2(100);',
'    l_validation_expression2 varchar2(4000);',
'    l_date                   date;',
'    l_date_format_mask       varchar2(100);',
'    l_timestamp              timestamp;',
'    l_result                 boolean := false; ',
'    l_func_result            varchar2(32767);',
'    l_min_max_values         apex_t_number;',
'    l_numeric_value          number;',
'begin',
'    apex_debug.message(p_message => ''%s Checking condition(s) for validation ...'', ',
'                       p0        => c_debug_msg_prefix);',
'',
'    if p_condition_type_code is not null then',
'    ',
'        -- Check the server side condition for the validation.',
'        -- When not fulfilled consider the validation as successful ',
'        -- as validation is not applicable',
'        if not apex_plugin_util.is_component_used (',
'               p_authorization_scheme_id => p_authorization_scheme_id,',
'               p_condition_type          => p_condition_type_code,',
'               p_condition_expression1   => p_condition_expression1,',
'               p_condition_expression2   => p_condition_expression2) then',
'               ',
'            apex_debug.message(p_message => ''%s ..... not passed --> skipping validation'', ',
'                               p0        => c_debug_msg_prefix);',
'            return true;',
'        end if;',
'    end if;     ',
'',
'    apex_debug.message(p_message => ''%s ..... passed'', p0 => c_debug_msg_prefix);',
'    ',
'    l_validation_type := p_validation_type;',
'',
'    apex_debug.message(p_message => ''%s Performing validation for validation type %s ....'',',
'                       p0 => c_debug_msg_prefix,',
'                       p1 => l_validation_type); ',
'    ',
'    case',
'        -- some validation types are equal to condition types ',
'        -- and can be validated with apex_plugin_util.is_component_used()',
'        when l_validation_type in (',
'             ''EXISTS'',''NOT_EXISTS'',''EXPRESSION'',''ITEM_REQUIRED'',',
'             ''ITEM_NOT_NULL'',''ITEM_NOT_NULL_OR_ZERO'',',
'             ''ITEM_NOT_ZERO'', ''ITEM_CONTAINS_NO_SPACES'',',
'             ''ITEM_IS_ALPHANUMERIC'',''ITEM_IS_NUMERIC'',',
'             ''ITEM_IN_VALIDATION_EQ_STRING2'', ',
'             ''ITEM_IN_VALIDATION_NOT_EQ_STRING2'',',
'             ''FUNC_BODY_RETURNING_BOOLEAN'') then',
'',
'            -- map from validation type to condition type',
'            case l_validation_type ',
'                when ''ITEM_IN_VALIDATION_EQ_STRING2'' then ',
'                    l_validation_type := ''VAL_OF_ITEM_IN_COND_EQ_COND2'';',
'                when ''ITEM_IN_VALIDATION_NOT_EQ_STRING2'' then ',
'                    l_validation_type := ''VAL_OF_ITEM_IN_COND_NOT_EQ_COND2'';',
'                when ''FUNC_BODY_RETURNING_BOOLEAN'' then',
'                    l_validation_type := ''FUNCTION_BODY'';',
'                when ''ITEM_REQUIRED'' then',
'                    l_validation_type := ''ITEM_IS_NOT_NULL'';',
'                when ''ITEM_NOT_NULL'' then',
'                    l_validation_type := ''ITEM_IS_NOT_NULL'';',
'                when ''ITEM_NOT_ZERO'' then',
'                    l_validation_type := ''ITEM_IS_NOT_ZERO'';',
'                else',
'                    l_validation_type := p_validation_type;',
'            end case;        ',
'               ',
'            l_result := apex_plugin_util.is_component_used (',
'                            p_authorization_scheme_id => null,',
'                            p_condition_type          => l_validation_type,',
'                            p_condition_expression1   => p_validation_expression1,',
'                            p_condition_expression2   => p_validation_expression2);',
'               ',
'        when l_validation_type = ''FUNC_BODY_RETURNING_ERR_TEXT'' then',
'            l_func_result := apex_plugin_util.get_plsql_function_result(',
'                                 p_plsql_function => p_validation_expression1',
'                             );',
'            if l_func_result is null then',
'                l_result := true;',
'            end if;',
'',
'        when l_validation_type = ''ITEM_IN_VALIDATION_IN_STRING2'' then',
'            l_validation_expression2 := apex_plugin_util.replace_substitutions(',
'                                            p_value => p_validation_expression2',
'                                        );',
'            if instr(l_validation_expression2, get_item_value(p_validation_expression1)) > 0 then',
'                l_result := true;',
'            end if;',
'               ',
'        when l_validation_type = ''ITEM_IN_VALIDATION_NOT_IN_STRING2'' then',
'             l_validation_expression2 := apex_plugin_util.replace_substitutions(',
'                                            p_value => p_validation_expression2',
'                                        );',
'            if instr(l_validation_expression2, get_item_value(p_validation_expression1)) = 0 then',
'                l_result := true;',
'            end if;',
'        ',
'        when l_validation_type = ''ITEM_IN_VALIDATION_CONTAINS_ONLY_CHAR_IN_STRING2'' then',
'            l_validation_expression2 := apex_plugin_util.replace_substitutions(',
'                                            p_value => p_validation_expression2',
'                                        );',
'            if regexp_instr(get_item_value(p_validation_expression1),',
'                            ''[^'' || escape_bracket_expression(l_validation_expression2) || '']'') = 0 then',
'                l_result := true;',
'            end if;    ',
'        ',
'        when l_validation_type = ''ITEM_IN_VALIDATION_CONTAINS_NO_CHAR_IN_STRING2'' then',
'            l_validation_expression2 := apex_plugin_util.replace_substitutions(',
'                                            p_value => p_validation_expression2',
'                                        );',
'            if regexp_instr(get_item_value(p_validation_expression1),',
'                            ''['' || escape_bracket_expression(l_validation_expression2) || '']'') = 0 then',
'                l_result := true;',
'            end if; ',
'            ',
'        when l_validation_type = ''ITEM_IN_VALIDATION_CONTAINS_AT_LEAST_ONE_CHAR_IN_STRING2'' then',
'            l_validation_expression2 := apex_plugin_util.replace_substitutions(',
'                                            p_value => p_validation_expression2',
'                                        );',
'            if regexp_instr(get_item_value(p_validation_expression1),',
'                            ''['' || escape_bracket_expression(l_validation_expression2) || '']'') > 0 then',
'                l_result := true;',
'            end if; ',
'',
'        when l_validation_type = ''REGULAR_EXPRESSION'' then',
'            l_validation_expression2 := apex_plugin_util.replace_substitutions(',
'                                            p_value => p_validation_expression2',
'                                        );',
'        ',
'            if regexp_like(get_item_value(p_validation_expression1), l_validation_expression2) then',
'                l_result := true;',
'            end if; ',
'        ',
'        when l_validation_type = ''ITEM_IS_DATE'' then',
'            -- get date format mask first',
'            select ',
'                format_mask ',
'            into ',
'                l_date_format_mask ',
'            from ',
'                apex_application_page_items',
'            where',
'                application_id = :APP_ID',
'                and item_name = p_validation_expression1;',
'',
'            begin',
'                if l_date_format_mask is null then',
'                    -- if no date format mask is given use the NLS_DATE_FORMAT session parameter',
'                    -- which is explicitly set by APEX before the AJAX request is executed',
'                    l_date := to_date(get_item_value(p_validation_expression1));',
'                else    ',
'                    l_date := to_date(get_item_value(p_validation_expression1), l_date_format_mask);',
'                end if;    ',
'                ',
'                l_result := true;',
'                ',
'            exception',
'                when others then l_result := false;',
'            end;',
'        ',
'        -- for native number fields check for numeric values using to_number()',
'        -- and for mininmum and maximum value settings (if applicable)',
'        when l_validation_type = ''NATIVE_NUMBER_FIELD'' then',
'            l_min_max_values := apex_string.split_numbers(',
'                                    p_str => p_validation_expression2,',
'                                    p_sep => '':'');',
'            begin',
'                l_numeric_value := to_number(get_item_value(p_validation_expression1));',
'                case ',
'                    when l_min_max_values(1) is not null and l_min_max_values(2) is not null then',
'                        if l_numeric_value between l_min_max_values(1) and l_min_max_values(2) then',
'                            l_result := true;',
'                        end if;',
'                    when l_min_max_values(1) is not null then',
'                        if l_numeric_value >= l_min_max_values(1) then',
'                            l_result := true;',
'                        end if;',
'                    when l_min_max_values(2) is not null then',
'                        if l_numeric_value <= l_min_max_values(2) then',
'                            l_result := true;',
'                        end if;',
'                    else',
'                        l_result := true; -- item has no min/max settings',
'                end case;',
'            ',
'            exception',
'                when VALUE_ERROR then l_result := false;',
'            end;',
'        else',
'            raise_application_error(-20555, ''Unsupported Validation Type: '' || nvl(p_validation_type,''NULL''));',
'    end case;',
'',
'    apex_debug.message(p_message => ''%s .....%s passed'', ',
'                       p0        => c_debug_msg_prefix,',
'                       p1        => case when l_result then '''' else '' NOT'' end); ',
'     ',
'    return l_result;',
'     ',
'end validate_item;',
'',
'     ',
'function render_validation (',
'    p_dynamic_action in apex_plugin.t_dynamic_action,',
'    p_plugin         in apex_plugin.t_plugin',
') return apex_plugin.t_dynamic_action_render_result ',
'is',
'    l_result apex_plugin.t_dynamic_action_render_result;',
'begin',
'    apex_javascript.add_library(',
'        p_name      => ''instant_validation.min'', ',
'        p_directory => p_plugin.file_prefix, ',
'        p_version    => null',
'    );',
'',
'    l_result.ajax_identifier := apex_plugin.get_ajax_identifier();',
'    ',
'    l_result.attribute_01 := p_dynamic_action.attribute_01;',
'    l_result.attribute_02 := p_dynamic_action.attribute_02;',
'    l_result.attribute_03 := p_dynamic_action.attribute_03;',
'',
'    l_result.javascript_function := ''function() { instant_validation(this); }'';',
'',
'    apex_plugin_util.debug_dynamic_action(',
'        p_plugin         => p_plugin, ',
'        p_dynamic_action => p_dynamic_action',
'    );',
'    ',
'    return l_result;',
'    ',
'exception',
'    when others then',
'        htp.p(sqlerrm);',
'        return l_result;',
'        ',
'end render_validation;',
'',
'',
'/**',
' * Perform all validations for the triggering element and prepare a json ',
' * response for the client',
' */',
'function ajax_validation (',
'    p_dynamic_action in apex_plugin.t_dynamic_action,',
'    p_plugin         in apex_plugin.t_plugin',
') return apex_plugin.t_dynamic_action_ajax_result is',
'',
'    l_result            apex_plugin.t_dynamic_action_ajax_result;',
'    l_item_id           varchar2(100)  := apex_application.g_x01;',
'    l_label             varchar2(1000);',
'    l_validation_type   varchar2(100);',
'    l_validation_passed boolean := true;',
'    l_validation_msg    varchar2(1000) := ''Validation passed successfully'';',
'    l_app_id            number := nv(''APP_ID'');',
'    l_page_id           number := nv(''APP_PAGE_ID'');',
'begin',
'    select',
'        label',
'    into',
'        l_label',
'    from',
'        apex_application_page_items',
'    where',
'        application_id = l_app_id',
'        and item_name = l_item_id;',
'',
'    -- get all validations associated with triggering item ',
'    for validation_rec in (',
'        select ',
'            validation_type_code,',
'            validation_name,',
'            validation_expression1,',
'            validation_expression2,',
'            validation_failure_text,',
'            condition_type,',
'            condition_type_code,',
'            condition_expression1,',
'            condition_expression2             ',
'        from',
'            apex_application_page_val',
'        where',
'            application_id = l_app_id',
'            and page_id = l_page_id',
'            and associated_item = l_item_id',
'		',
'        union all',
'        select',
'            display_as_code,',
'            display_as_code,',
'            l_item_id,',
'            attribute_01 || '':'' || attribute_02,',
'            case ',
'                when attribute_01 is not null and attribute_02 is not null then',
'                    apex_lang.message(p_name => ''APEX.NUMBER_FIELD.VALUE_NOT_BETWEEN_MIN_MAX'',',
'                                      p0     => attribute_01,',
'                                      p1     => attribute_02) ',
'                when attribute_01 is not null then',
'                    apex_lang.message(p_name => ''APEX.NUMBER_FIELD.VALUE_GREATER_MAX_VALUE'',',
'                                      p0     => attribute_01)',
'                when attribute_02 is not null then',
'                    apex_lang.message(p_name => ''APEX.NUMBER_FIELD.VALUE_LESS_MIN_VALUE'',',
'                                      p0     => attribute_01)',
'                else',
'                    ''''',
'            end,',
'            null,',
'            null,',
'            null,',
'            null',
'        from',
'            apex_application_page_items',
'        where',
'            application_id = l_app_id',
'            and page_id = l_page_id',
'            and item_name = l_item_id',
'            and display_as_code = ''NATIVE_NUMBER_FIELD''',
'        ',
'        -- ITEM_REQUIRED is validated as HTML5 validation in the browser.',
'        -- To prevent javascript manupulation on the client we validate',
'        -- the ITEM_REQUIRED validation on the server as well ',
'        union all',
'        select',
'            ''ITEM_REQUIRED'',',
'            ''ITEM_REQUIRED'',',
'            l_item_id,',
'            format_mask,',
'            apex_lang.message(''APEX.PAGE_ITEM_IS_REQUIRED''),',
'            null,',
'            null,',
'            null,',
'            null',
'        from',
'            apex_application_page_items',
'        where',
'            application_id = l_app_id',
'            and page_id = l_page_id',
'            and item_name = l_item_id',
'            and lower(is_required) = ''yes''',
'',
'    ) loop',
' ',
'        if not validate_item(',
'            p_validation_type         => validation_rec.validation_type_code,',
'            p_validation_expression1  => validation_rec.validation_expression1,',
'            p_validation_expression2  => validation_rec.validation_expression2,',
'            p_authorization_scheme_id => null,',
'            p_condition_type_code     => validation_rec.condition_type_code,',
'            p_condition_expression1   => validation_rec.condition_expression1,',
'            p_condition_expression2   => validation_rec.condition_expression2) then',
'            ',
'            l_validation_type   := validation_rec.validation_type_code;',
'            l_validation_passed := false;',
'            l_validation_msg    := replace(validation_rec.validation_failure_text, ''#LABEL#'', l_label);',
'            ',
'            -- stop further validation in case validation failed',
'            exit;                         ',
'        end if;    ',
'            ',
'    end loop;',
'    ',
'    -- generate the json output ',
'    apex_json.open_object;',
'    apex_json.open_object(''validationResult'');',
'    apex_json.write(''item'', l_item_id);',
'    apex_json.write(''validationType'', l_validation_type);',
'    apex_json.write(''passed'', l_validation_passed);         ',
'    apex_json.write(''message'', l_validation_msg);',
'    apex_json.close_all;',
'',
'    return l_result;',
'    ',
'end ajax_validation;'))
,p_api_version=>2
,p_render_function=>'render_validation'
,p_ajax_function=>'ajax_validation'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_version_identifier=>'1.0.0'
,p_about_url=>'https://github.com/christian-hesse/instant-validation-plugin'
,p_files_version=>82
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(14791751505471186)
,p_plugin_id=>wwv_flow_api.id(14788259458149065)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Items to Submit'
,p_attribute_type=>'PAGE ITEMS'
,p_is_required=>false
,p_is_translatable=>false
,p_examples=>'If a validation expression or the validation condition for the tirggering page item depends on another page item enter the page item name here.'
,p_help_text=>'Enter a list of comma separated page items to be submitted. The triggering page item gets always submitted (default).'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(8688205148180957)
,p_plugin_id=>wwv_flow_api.id(14788259458149065)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Show Validation Progress Indicator'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'Y'
,p_is_translatable=>false
,p_help_text=>'If true, a ''Wait Indicator'' spinner is displayed next to the triggering page item. Depending on the duration of the AJAX call the spinner may not show up (for low duration AJAX calls). If false no spinner will be displayed.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(8688567435185371)
,p_plugin_id=>wwv_flow_api.id(14788259458149065)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Render Error'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'Y'
,p_is_translatable=>false
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>To implement a simple custom validation error rendering we could change the background of the triggering item to red color and show the error message in the items standard error placeholder:</p>',
'',
'<p>Create a new <code>Dynamic Action</code>, choose <code>Instant Validation Failure [Instant Item Validation]</code> as <code>Event</code>.</p>',
'',
'<p>To implement a global error rendering function use <code>Javascript Expression</code> as <code>Selection Type</code> and enter <code>document</code> as <code>Javascript Expression</code>. Alternatively to implement custom error rending for a speci'
||'fic page item choose <code>Item</code> for <code>Selection Type</code> and select the item.',
'Create a <code>True Action</code> and choose <code>Execute Javascript Code</code> and enter the following code:',
'<pre>',
'let validationResult = this.data.validationResult;',
'',
'$(''#'' + validationResult.item).addClass(''hasError'');',
'$(''#'' + validationResult.item + ''_error_placeholder'').text(validationResult.message);',
'</pre>',
'</p>',
'',
'<p>Create a new <code>Dynamic Action</code>, choose <code>Instant Validation Success [Instant Item Validation]</code> as <code>Event</code>.</p>',
'<p>Choose the same <code>Selection Type</code> as above and enter the following code as <code>Execute Javascript Code</code> in the <code>True Action</code>',
'<pre>',
'let validationResult = this.data.validationResult;',
'',
'$(''#'' + validationResult.item).removeClass(''hasError'');',
'$(''#'' + validationResult.item + ''_error_placeholder'').text('''');',
'</pre>',
'</p>',
'',
'In page inline css (or external css file) add a css class definition:',
'<pre>',
'.hasError {',
'    background-color: #eea29a;',
'}',
'</pre>'))
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'If true, a validation error will be displayed according to standard APEX validation error rendering. If false, no error rendering will be displayed. ',
'<br /><br />',
'Use false if you want to implement your own error rendering using the JavaScript plugin events <code>validation-success</code> and <code>validation-failure</code>.',
'You can bind a Dynamic Action to each plugin event to excecute custom JavaScript code for validation error rendering.'))
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(8690130209194863)
,p_plugin_id=>wwv_flow_api.id(14788259458149065)
,p_name=>'validation-error'
,p_display_name=>'Instant Validation Error'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(8690538725194864)
,p_plugin_id=>wwv_flow_api.id(14788259458149065)
,p_name=>'validation-failure'
,p_display_name=>'Instant Validation Failure'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(8690973030194865)
,p_plugin_id=>wwv_flow_api.id(14788259458149065)
,p_name=>'validation-start'
,p_display_name=>'Instant Validation Start'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(8691384463194866)
,p_plugin_id=>wwv_flow_api.id(14788259458149065)
,p_name=>'validation-success'
,p_display_name=>'Instant Validation Succes'
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '66756E6374696F6E20696E7374616E745F76616C69646174696F6E2874297B636F6E737420653D22617065782D706167652D6974656D2D6572726F72223B66756E6374696F6E206128742C61297B742E616464436C6173732865292C24282223222B742E';
wwv_flow_api.g_varchar2_table(2) := '617474722822696422292B225F6572726F725F706C616365686F6C64657222292E746578742861297D6C657420693D2428742E74726967676572696E67456C656D656E74292C723D692E617474722822696422292C6E3D7B6974656D73546F5375626D69';
wwv_flow_api.g_varchar2_table(3) := '743A742E616374696F6E2E61747472696275746530312C73686F77496E64696361746F723A742E616374696F6E2E61747472696275746530322C72656E6465724572726F723A742E616374696F6E2E61747472696275746530337D2C6F3D66756E637469';
wwv_flow_api.g_varchar2_table(4) := '6F6E28742C65297B72657475726E206E756C6C3D3D3D657C7C303D3D3D652E7472696D28292E6C656E6774683F5B745D3A652E73706C697428222C22292E636F6E636174285B745D297D28722C6E2E6974656D73546F5375626D6974293B617065782E65';
wwv_flow_api.g_varchar2_table(5) := '76656E742E7472696767657228692C2276616C69646174696F6E2D737461727422292C617065782E646562756728275B496E7374616E742076616C69646174696F6E5D3A2076616C69646174696F6E207374617274656420666F72206974656D2022272B';
wwv_flow_api.g_varchar2_table(6) := '722B272227293B6C657420643D617065782E6974656D2872292C6C3D642E67657456616C696469747928293B696628216C2E76616C6964297B617065782E646562756728275B496E7374616E742076616C69646174696F6E5D3A2076616C69646174696F';
wwv_flow_api.g_varchar2_table(7) := '6E20666F72206974656D2022272B722B272220656E6465642077697468206661696C75726527293B6C657420742C653D642E67657456616C69646174696F6E4D65737361676528293B72657475726E206C2E7061747465726E4D69736D617463683F743D';
wwv_flow_api.g_varchar2_table(8) := '225041545445524E5F4D49534D41544348223A6C2E76616C75654D697373696E673F743D224954454D5F5245515549524544223A6C2E637573746F6D4572726F72262628743D22435553544F4D5F4552524F5222292C2259223D3D3D6E2E72656E646572';
wwv_flow_api.g_varchar2_table(9) := '4572726F7226266128692C65292C766F696420617065782E6576656E742E7472696767657228692C2276616C69646174696F6E2D6661696C757265222C7B76616C69646174696F6E526573756C743A7B6974656D3A722C76616C69646174696F6E547970';
wwv_flow_api.g_varchar2_table(10) := '653A742C7061737365643A21312C6D6573736167653A657D7D297D6C657420733D7B7830313A722C706167654974656D733A6F7D2C753D7B6C6F6164696E67496E64696361746F723A2259223D3D3D6E2E73686F77496E64696361746F723F693A6E756C';
wwv_flow_api.g_varchar2_table(11) := '6C2C737563636573733A66756E6374696F6E2874297B313D3D742E76616C69646174696F6E526573756C742E7061737365643F28617065782E646562756728275B496E7374616E742076616C69646174696F6E5D3A2076616C69646174696F6E20666F72';
wwv_flow_api.g_varchar2_table(12) := '206974656D2022272B722B272220656E6465642077697468207375636365737327292C2259223D3D3D6E2E72656E6465724572726F72262666756E6374696F6E2874297B742E72656D6F7665436C6173732865292C24282223222B742E61747472282269';
wwv_flow_api.g_varchar2_table(13) := '6422292B225F6572726F725F706C616365686F6C64657222292E74657874282222297D2869292C617065782E6576656E742E7472696767657228692C2276616C69646174696F6E2D73756363657373222C7429293A28617065782E646562756728275B49';
wwv_flow_api.g_varchar2_table(14) := '6E7374616E742076616C69646174696F6E5D3A2076616C69646174696F6E20666F72206974656D2022272B722B272220656E6465642077697468206661696C75726527292C2259223D3D3D6E2E72656E6465724572726F7226266128692C742E76616C69';
wwv_flow_api.g_varchar2_table(15) := '646174696F6E526573756C742E6D657373616765292C617065782E6576656E742E7472696767657228692C2276616C69646174696F6E2D6661696C757265222C7429297D2C6572726F723A66756E6374696F6E28742C65297B617065782E646562756728';
wwv_flow_api.g_varchar2_table(16) := '225B496E7374616E742076616C69646174696F6E5D3A204572726F723A20222B742B225C6E222B65292C617065782E6576656E742E7472696767657228692C2276616C69646174696F6E2D6572726F7222297D7D3B617065782E7365727665722E706C75';
wwv_flow_api.g_varchar2_table(17) := '67696E28742E616374696F6E2E616A61784964656E7469666965722C732C75297D';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(9427983170849005)
,p_plugin_id=>wwv_flow_api.id(14788259458149065)
,p_file_name=>'instant_validation.min.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '66756E6374696F6E20696E7374616E745F76616C69646174696F6E28206F626A2029207B0D0A0D0A20202020636F6E7374206572726F72436C617373203D2027617065782D706167652D6974656D2D6572726F72273B0D0A0D0A2020202066756E637469';
wwv_flow_api.g_varchar2_table(2) := '6F6E206765744974656D73546F5375626D697428206974656D2C206164646974696F6E616C4974656D73546F5375626D69742029207B0D0A0D0A2020202020202020696628206164646974696F6E616C4974656D73546F5375626D6974203D3D3D206E75';
wwv_flow_api.g_varchar2_table(3) := '6C6C2029207B0D0A20202020202020202020202072657475726E205B6974656D5D3B0D0A20202020202020207D200D0A0D0A2020202020202020696628206164646974696F6E616C4974656D73546F5375626D69742E7472696D28292E6C656E67746820';
wwv_flow_api.g_varchar2_table(4) := '3D3D3D20302029207B0D0A20202020202020202020202072657475726E205B6974656D5D3B0D0A20202020202020207D0D0A202020202020202020200D0A202020202020202072657475726E206164646974696F6E616C4974656D73546F5375626D6974';
wwv_flow_api.g_varchar2_table(5) := '2E73706C697428272C27292E636F6E636174285B6974656D5D293B0D0A202020207D0D0A0D0A2020202066756E6374696F6E207365744572726F7228206974656D2C206572726F724D6573736167652029207B0D0A0D0A20202020202020202F2F205765';
wwv_flow_api.g_varchar2_table(6) := '20617265206E6F74207573696E6720617065782E6D6573736167652E73686F774572726F7273282920686572650D0A20202020202020202F2F2073696E636520697420726571756972657320746F2063616C6C20617065782E6D6573736167652E636C65';
wwv_flow_api.g_varchar2_table(7) := '61724572726F727328292066697273742E0D0A20202020202020202F2F2054686572652069732063757272656E746C79206E6F2077617920746F20636C656172206572726F72206D6573736167657320666F720D0A20202020202020202F2F20696E6469';
wwv_flow_api.g_varchar2_table(8) := '76696475616C2070616765206974656D732E0D0A0D0A20202020202020206974656D2E616464436C617373286572726F72436C617373293B0D0A20202020202020202428272327202B206974656D2E61747472282769642729202B20275F6572726F725F';
wwv_flow_api.g_varchar2_table(9) := '706C616365686F6C64657227292E74657874286572726F724D657373616765293B0D0A202020207D0D0A0D0A2020202066756E6374696F6E2072657365744572726F7228206974656D2029207B0D0A0D0A20202020202020206974656D2E72656D6F7665';
wwv_flow_api.g_varchar2_table(10) := '436C617373286572726F72436C617373293B0D0A20202020202020202428272327202B206974656D2E61747472282769642729202B20275F6572726F725F706C616365686F6C64657227292E74657874282727293B0D0A202020207D0D0A0D0A20202020';
wwv_flow_api.g_varchar2_table(11) := '6C65742074726967676572696E674974656D2020203D2024286F626A2E74726967676572696E67456C656D656E74292C0D0A202020202020202074726967676572696E674974656D4964203D2074726967676572696E674974656D2E6174747228276964';
wwv_flow_api.g_varchar2_table(12) := '27292C0D0A2020202020202020706C7567696E41747472696275746573203D207B0D0A20202020202020202020202020202020202020202020202020202020206974656D73546F5375626D69743A206F626A2E616374696F6E2E61747472696275746530';
wwv_flow_api.g_varchar2_table(13) := '312C0D0A202020202020202020202020202020202020202020202020202020202073686F77496E64696361746F723A206F626A2E616374696F6E2E61747472696275746530322C0D0A202020202020202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(14) := '202072656E6465724572726F723A2020206F626A2E616374696F6E2E61747472696275746530330D0A2020202020202020202020202020202020202020202020202020207D2C0D0A20202020202020206974656D73546F5375626D6974202020203D2067';
wwv_flow_api.g_varchar2_table(15) := '65744974656D73546F5375626D69742874726967676572696E674974656D49642C20706C7567696E417474726962757465732E6974656D73546F5375626D6974293B0D0A0D0A20202020617065782E6576656E742E747269676765722874726967676572';
wwv_flow_api.g_varchar2_table(16) := '696E674974656D2C202776616C69646174696F6E2D737461727427293B0D0A20202020617065782E646562756728275B496E7374616E742076616C69646174696F6E5D3A2076616C69646174696F6E207374617274656420666F72206974656D20222720';
wwv_flow_api.g_varchar2_table(17) := '2B2074726967676572696E674974656D4964202B20272227293B0D0A0D0A202020202F2F20706572666F726D20636C69656E7420736964652048544D4C352076616C69646174696F6E0D0A202020206C6574206974656D203D20617065782E6974656D28';
wwv_flow_api.g_varchar2_table(18) := '74726967676572696E674974656D4964292C0D0A20202020202020206974656D56616C6964697479203D206974656D2E67657456616C696469747928293B0D0A0D0A2020202069662820216974656D56616C69646974792E76616C69642029207B0D0A20';
wwv_flow_api.g_varchar2_table(19) := '20202020202020617065782E646562756728275B496E7374616E742076616C69646174696F6E5D3A2076616C69646174696F6E20666F72206974656D202227202B2074726967676572696E674974656D4964202B20272220656E64656420776974682066';
wwv_flow_api.g_varchar2_table(20) := '61696C75726527293B0D0A0D0A20202020202020206C65742076616C69646174696F6E4572726F724D7367203D206974656D2E67657456616C69646174696F6E4D65737361676528292C0D0A20202020202020202020202076616C69646174696F6E5479';
wwv_flow_api.g_varchar2_table(21) := '70654661696C65643B0D0A0D0A2020202020202020696628206974656D56616C69646974792E7061747465726E4D69736D617463682029207B0D0A20202020202020202020202076616C69646174696F6E547970654661696C6564203D20275041545445';
wwv_flow_api.g_varchar2_table(22) := '524E5F4D49534D41544348273B0D0A20202020202020207D20656C736520696628206974656D56616C69646974792E76616C75654D697373696E672029207B0D0A20202020202020202020202076616C69646174696F6E547970654661696C6564203D20';
wwv_flow_api.g_varchar2_table(23) := '274954454D5F5245515549524544273B0D0A20202020202020207D20656C736520696628206974656D56616C69646974792E637573746F6D4572726F722029207B0D0A20202020202020202020202076616C69646174696F6E547970654661696C656420';
wwv_flow_api.g_varchar2_table(24) := '3D2027435553544F4D5F4552524F52273B0D0A20202020202020207D0D0A0D0A202020202020202069662820706C7567696E417474726962757465732E72656E6465724572726F72203D3D3D202759272029207B0D0A2020202020202020202020207365';
wwv_flow_api.g_varchar2_table(25) := '744572726F722874726967676572696E674974656D2C2076616C69646174696F6E4572726F724D7367293B0D0A20202020202020207D0D0A0D0A2020202020202020617065782E6576656E742E747269676765722874726967676572696E674974656D2C';
wwv_flow_api.g_varchar2_table(26) := '202776616C69646174696F6E2D6661696C757265272C207B0D0A2020202020202020202020202276616C69646174696F6E526573756C74223A7B0D0A2020202020202020202020202020202020226974656D223A2074726967676572696E674974656D49';
wwv_flow_api.g_varchar2_table(27) := '640D0A202020202020202020202020202020202C2276616C69646174696F6E54797065223A2076616C69646174696F6E547970654661696C65640D0A202020202020202020202020202020202C22706173736564223A2066616C73650D0A202020202020';
wwv_flow_api.g_varchar2_table(28) := '202020202020202020202C226D657373616765223A2076616C69646174696F6E4572726F724D73670D0A2020202020202020202020207D0D0A20202020202020207D293B0D0A20202020202020200D0A202020202020202072657475726E3B0D0A202020';
wwv_flow_api.g_varchar2_table(29) := '207D0D0A0D0A202020202F2F20706572666F726D207365727665722D736964652076616C69646174696F6E2076696120414A41582063616C6C0D0A202020206C657420616A617844617461203D207B0D0A2020202020202020202020207830313A207472';
wwv_flow_api.g_varchar2_table(30) := '6967676572696E674974656D49642C0D0A202020202020202020202020706167654974656D733A206974656D73546F5375626D6974200D0A20202020202020207D2C0D0A2020202020202020616A61784F7074696F6E73203D207B0D0A20202020202020';
wwv_flow_api.g_varchar2_table(31) := '20202020206C6F6164696E67496E64696361746F723A20706C7567696E417474726962757465732E73686F77496E64696361746F72203D3D3D20275927203F2074726967676572696E674974656D203A206E756C6C2C200D0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(32) := '2073756363657373203A2066756E6374696F6E2820726573756C742029207B200D0A20202020202020202020202020202020202020202020202020206966202820726573756C742E76616C69646174696F6E526573756C742E706173736564203D3D2074';
wwv_flow_api.g_varchar2_table(33) := '72756529207B0D0A202020202020202020202020202020202020202020202020202020202020617065782E646562756728275B496E7374616E742076616C69646174696F6E5D3A2076616C69646174696F6E20666F72206974656D202227202B20747269';
wwv_flow_api.g_varchar2_table(34) := '67676572696E674974656D4964202B20272220656E6465642077697468207375636365737327293B0D0A20202020202020202020202020202020202020202020202020202020202069662820706C7567696E417474726962757465732E72656E64657245';
wwv_flow_api.g_varchar2_table(35) := '72726F72203D3D3D202759272029207B0D0A2020202020202020202020202020202020202020202020202020202020202020202072657365744572726F722874726967676572696E674974656D293B0D0A20202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(36) := '20202020202020202020207D0D0A202020202020202020202020202020202020202020202020202020202020617065782E6576656E742E747269676765722874726967676572696E674974656D2C202776616C69646174696F6E2D73756363657373272C';
wwv_flow_api.g_varchar2_table(37) := '20726573756C74293B0D0A20202020202020202020202020202020202020202020202020207D200D0A2020202020202020202020202020202020202020202020202020656C7365207B0D0A20202020202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(38) := '2020202020617065782E646562756728275B496E7374616E742076616C69646174696F6E5D3A2076616C69646174696F6E20666F72206974656D202227202B2074726967676572696E674974656D4964202B20272220656E646564207769746820666169';
wwv_flow_api.g_varchar2_table(39) := '6C75726527293B0D0A20202020202020202020202020202020202020202020202020202020202069662820706C7567696E417474726962757465732E72656E6465724572726F72203D3D3D202759272029207B0D0A202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(40) := '202020202020202020202020202020202020207365744572726F722874726967676572696E674974656D2C20726573756C742E76616C69646174696F6E526573756C742E6D657373616765293B0D0A202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(41) := '2020202020202020207D0D0A202020202020202020202020202020202020202020202020202020202020617065782E6576656E742E747269676765722874726967676572696E674974656D2C202776616C69646174696F6E2D6661696C757265272C2072';
wwv_flow_api.g_varchar2_table(42) := '6573756C74293B0D0A20202020202020202020202020202020202020202020202020207D0D0A20202020202020202020202020202020202020202020202020200D0A202020202020202020202020202020202020202020207D2C0D0A2020202020202020';
wwv_flow_api.g_varchar2_table(43) := '202020206572726F723A2066756E6374696F6E28746578745374617475732C206572726F725468726F776E29207B200D0A2020202020202020202020202020202020202020202020617065782E646562756728275B496E7374616E742076616C69646174';
wwv_flow_api.g_varchar2_table(44) := '696F6E5D3A204572726F723A2027202B2074657874537461747573202B20275C6E27202B206572726F725468726F776E293B0D0A2020202020202020202020202020202020202020202020617065782E6576656E742E7472696767657228747269676765';
wwv_flow_api.g_varchar2_table(45) := '72696E674974656D2C202776616C69646174696F6E2D6572726F7227293B0D0A202020202020202020202020202020202020207D0D0A20202020202020207D3B0D0A0D0A20202020617065782E7365727665722E706C7567696E286F626A2E616374696F';
wwv_flow_api.g_varchar2_table(46) := '6E2E616A61784964656E7469666965722C20616A6178446174612C20616A61784F7074696F6E73293B0920200D0A7D';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(14788535368184018)
,p_plugin_id=>wwv_flow_api.id(14788259458149065)
,p_file_name=>'instant_validation.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
prompt --application/end_environment
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false));
commit;
end;
/
set verify on feedback on define on
prompt  ...done
