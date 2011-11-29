<?php

/**
 * Implements hook_form_FORM_ID_alter().
 * 
 */
function cmtls_profile_form_install_configure_form_alter(&$form, $form_state) {
  
  // Pre-populate the site name with the server name.
  $form['site_information']['site_name']['#default_value'] = 'CT '.$_SERVER['SERVER_NAME'];
  
  // add site slogan field
  $form['site_information']['site_slogan'] = array(
    '#type' => 'textfield',
    '#title' => st('Site slogan'),
    '#default_value' => 'Making better communities',
    '#description' => st('Slogan for your site'),
    '#weight' => -19,
  );
  
  $form['site_information']['googlemap_api_key'] = array(
    '#title' => st('Google Maps API Key'),
    '#description' => st('If you wish to use maps on this site set your personal Googlemaps API key.  You must get this for each separate website at <a href="http://code.google.com/apis/maps/signup.html" target="_blank">Google Map API website</a>.'),
    '#type' => 'textfield',
    '#default_value' => variable_get('googlemap_api_key', ''),
    '#weight' => 30,
    '#size' => 50,
    '#maxlength' => 255,
  );
  
  $form['#submit'][] = '_cmtls_profile_install_save';
  
  if($_GET['locale'] == 'et') {
    // turn off timezone detection
    unset($form['server_settings']['date_default_timezone']['#attributes']['class'][0]);
  }
  
  // by default turn off the automated update check
  $form['update_notifications']['update_status_module']['#default_value'] = array();
}

function _cmtls_profile_install_save($form, &$form_state) {
  global $user;
  
  if($form_state['values']['googlemap_api_key']) {
    variable_set('googlemap_api_key', $form_state['values']['googlemap_api_key']);
    variable_set('location_usegmap', 1);
  }

  variable_set('site_slogan', $form_state['values']['site_slogan']);
}


