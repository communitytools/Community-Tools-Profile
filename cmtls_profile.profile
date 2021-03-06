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

  // ID, apikey and secret are shown on facebook.  User copies and pastes values.
  $form['site_information']['fb_apikey'] = array(
    '#type' => 'textfield',
    '#title' => st('Facebook App ID'),
    '#description' => st('Facebook will generate this value when you create the application.'),
  );

  $form['site_information']['fb_secret'] = array(
    '#type' => 'textfield',
    '#title' => st('Facebook APP Secret'),
    '#description' => st('Facebook will generate this value when you create the application.'),
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

  // Name the main group the same as the site name.
  $main_group = node_load(1);
  $main_group->title = $form_state['values']['site_name'];
  node_save($main_group);

  $fb_app = array(
    'status' => ($form_state['values']['fb_secret'] && $form_state['values']['fb_apikey'] ?  1 : 0),
    'label' => 'cmtls_fb',
    'title' => 'cmtls_fb',
    'apikey' => $form_state['values']['fb_apikey'],
    'id' => $form_state['values']['fb_apikey'],
    'secret' => $form_state['values']['fb_secret'],
    'data' => serialize(array(
      'fb_app' => array(
        'set_app_props' => 1,
      ),
      'fb_connect' => array(
        'primary' => 1,
      ),
      'fb_user' => array(
        'create_account' => '2',
        'map_account' => array(
          2 => 0,
          3 => 0,
        ),
        'new_user_rid' => '0',
        'connected_user_rid' => '0',
      ),
    )),
  );

  // facebook app
  $fb_app['fba_id'] = db_insert('fb_app')
    ->fields($fb_app)
    ->execute();

  // facebook configs
  variable_set('fb_connect_primary_label', 'cmtls_fb');
  variable_set('fb_user_username_style', 1);

  if($form_state['values']['fb_secret'] && $form_state['values']['fb_apikey']) {
    module_load_include('inc', 'fb_app', 'fb_app.admin');
    fb_app_set_app_properties((object)$fb_app);
  }

  variable_set('site_slogan', $form_state['values']['site_slogan']);
}

