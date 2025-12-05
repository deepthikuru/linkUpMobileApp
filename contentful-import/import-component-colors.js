/**
 * Contentful Component Colors Import Script
 * 
 * This script imports all component colors into Contentful using the Management API.
 * 
 * Usage:
 *   1. Install dependencies: npm install contentful-management
 *   2. Set environment variables:
 *      - CONTENTFUL_SPACE_ID: Your Contentful space ID
 *      - CONTENTFUL_MANAGEMENT_TOKEN: Your Contentful Management API token
 *   3. Run: node import-component-colors.js
 * 
 * Or pass as arguments:
 *   node import-component-colors.js --space-id=YOUR_SPACE_ID --token=YOUR_TOKEN
 */

const contentful = require('contentful-management');
const fs = require('fs');
const path = require('path');

// Component colors data
const componentColors = [
  { componentId: 'main_elevatedButton_background', backgroundColor: '#014D7D' },
  { componentId: 'main_elevatedButton_text', textColor: '#FFFFFF' },
  { componentId: 'home_scaffold_background', backgroundColor: '#FFFFFF' },
  { componentId: 'home_title_text', textColor: '#000000' },
  { componentId: 'home_subtitle_text', textColor: '#757575' },
  { componentId: 'home_sectionTitle_text', textColor: '#000000' },
  { componentId: 'home_description_text', textColor: '#757575' },
  { componentId: 'home_signOutButton_background', backgroundColor: '#FF0000' },
  { componentId: 'home_signOutButton_text', textColor: '#FFFFFF' },
  { componentId: 'login_scaffold_background', backgroundColor: '#FFFFFF' },
  { componentId: 'login_title_text', textColor: '#000000' },
  { componentId: 'login_inputHint_text', textColor: '#757575' },
  { componentId: 'login_input_background', backgroundColor: '#FFFFFF' },
  { componentId: 'login_signInButton_disabledBackground', backgroundColor: '#757575' },
  { componentId: 'login_signInButton_text', textColor: '#FFFFFF' },
  { componentId: 'login_loadingIndicator_color', iconColor: '#FFFFFF' },
  { componentId: 'login_separator_text', textColor: '#757575' },
  { componentId: 'login_googleButton_background', backgroundColor: '#FF0000' },
  { componentId: 'login_googleButton_text', textColor: '#FFFFFF' },
  { componentId: 'login_googleButton_icon', iconColor: '#FFFFFF' },
  { componentId: 'login_appleButton_background', backgroundColor: '#000000' },
  { componentId: 'login_appleButton_text', textColor: '#FFFFFF' },
  { componentId: 'login_appleButton_icon', iconColor: '#FFFFFF' },
  { componentId: 'login_footerText_text', textColor: '#000000' },
  { componentId: 'login_errorSnackbar_background', backgroundColor: '#FF0000' },
  { componentId: 'login_successSnackbar_background', backgroundColor: '#4CAF50' },
  { componentId: 'splash_scaffold_background', backgroundColor: '#FFFFFF' },
  { componentId: 'splash_loadingIndicator_color', iconColor: '#757575' },
  { componentId: 'gradientButton_gradientStart', gradientStartColor: '#014D7D', gradientEndColor: '#0C80C3' },
  { componentId: 'gradientButton_gradientEnd', gradientStartColor: '#014D7D', gradientEndColor: '#0C80C3' },
  { componentId: 'gradientButton_disabledBackground', backgroundColor: '#757575' },
  { componentId: 'gradientButton_text', textColor: '#FFFFFF' },
  { componentId: 'gradientButton_loadingIndicator', iconColor: '#FFFFFF' },
  { componentId: 'planCard_background', backgroundColor: '#FFFFFF' },
  { componentId: 'planCard_border', borderColor: '#757575' },
  { componentId: 'planCard_borderSelected', borderColor: '#014D7D' },
  { componentId: 'planCard_badgeGradientStart', gradientStartColor: '#014D7D', gradientEndColor: '#0C80C3' },
  { componentId: 'planCard_badgeGradientEnd', gradientStartColor: '#014D7D', gradientEndColor: '#0C80C3' },
  { componentId: 'planCard_badgeBackground', backgroundColor: '#E3F2FD' },
  { componentId: 'planCard_badgeBorder', borderColor: '#66B3FF' },
  { componentId: 'planCard_badgeTextSelected', textColor: '#FFFFFF' },
  { componentId: 'planCard_badgeText', textColor: '#014D7D' },
  { componentId: 'planCard_price_text', textColor: '#014D7D' },
  { componentId: 'planCard_planNameSmall_text', textColor: '#424242' },
  { componentId: 'planCard_planName_text', textColor: '#757575' },
  { componentId: 'planCard_divider', borderColor: '#E0E0E0' },
  { componentId: 'planCard_featureIcon', iconColor: '#014D7D' },
  { componentId: 'planCard_featureLabel_text', textColor: '#757575' },
  { componentId: 'appHeader_gradientStart', gradientStartColor: '#014D7D', gradientEndColor: '#0C80C3' },
  { componentId: 'appHeader_gradientEnd', gradientStartColor: '#014D7D', gradientEndColor: '#0C80C3' },
  { componentId: 'appHeader_backIcon', iconColor: '#000000' },
  { componentId: 'appHeader_backIcon_gradient', iconColor: '#FFFFFF' },
  { componentId: 'appHeader_titleText', textColor: '#000000' },
  { componentId: 'appHeader_titleText_gradient', textColor: '#FFFFFF' },
  { componentId: 'appHeader_zipCodeText', textColor: '#000000' },
  { componentId: 'appHeader_zipCodeText_gradient', textColor: '#FFFFFF' },
  { componentId: 'appHeader_zipIcon', iconColor: '#757575' },
  { componentId: 'appHeader_zipIcon_gradient', iconColor: '#FFFFFF' },
  { componentId: 'appHeader_menuIcon', iconColor: '#000000' },
  { componentId: 'appHeader_menuIcon_gradient', iconColor: '#FFFFFF' },
  { componentId: 'appFooter_background', backgroundColor: '#FFFFFF' },
  { componentId: 'appFooter_shadow', shadowColor: '#1A000000' },
  { componentId: 'appFooter_tabIcon_selected', iconColor: '#FDC710' },
  { componentId: 'appFooter_tabIcon', iconColor: '#757575' },
  { componentId: 'appFooter_tabLabel_selected', textColor: '#FDC710' },
  { componentId: 'appFooter_tabLabel', textColor: '#757575' },
  { componentId: 'bottomActionBar_background', backgroundColor: '#FFFFFF' },
  { componentId: 'stepIndicator_gradientStart', gradientStartColor: '#014D7D', gradientEndColor: '#0C80C3' },
  { componentId: 'stepIndicator_gradientEnd', gradientStartColor: '#014D7D', gradientEndColor: '#0C80C3' },
  { componentId: 'stepIndicator_text', textColor: '#FFFFFF' },
  { componentId: 'stepNavigation_scaffold_background', backgroundColor: '#FFFFFF' },
  { componentId: 'stepNavigation_backIcon', iconColor: '#FDC710' },
  { componentId: 'stepNavigation_cancelIcon', iconColor: '#FDC710' },
  { componentId: 'stepNavigation_cancelButtonText', textColor: '#FF0000' },
  { componentId: 'stepNavigation_footer_background', backgroundColor: '#FFFFFF' },
  { componentId: 'orderCard_background', backgroundColor: '#FFFFFF' },
  { componentId: 'orderCard_border', borderColor: '#E0E0E0' },
  { componentId: 'orderCard_status_completed', iconColor: '#4CAF50' },
  { componentId: 'orderCard_status_cancelled', iconColor: '#FF0000' },
  { componentId: 'orderCard_status_inProgress', iconColor: '#FF9800' },
  { componentId: 'orderCard_date_text', textColor: '#757575' },
  { componentId: 'orderCard_phoneNumber_text', textColor: '#757575' },
  { componentId: 'orderCard_chevronIcon', iconColor: '#757575' },
  { componentId: 'planCarousel_indicatorActive_gradientStart', gradientStartColor: '#014D7D', gradientEndColor: '#0C80C3' },
  { componentId: 'planCarousel_indicatorActive_gradientEnd', gradientStartColor: '#014D7D', gradientEndColor: '#0C80C3' },
  { componentId: 'planCarousel_indicatorInactive', backgroundColor: '#E0E0E0' },
  { componentId: 'offlineBanner_background', backgroundColor: '#FFF9E6' },
  { componentId: 'offlineBanner_icon', iconColor: '#FDC710' },
  { componentId: 'offlineBanner_text', textColor: '#757575' },
  { componentId: 'mainLayout_scaffold_background', backgroundColor: '#FFFFFF' },
  { componentId: 'mainLayout_dialogBarrier', shadowColor: '#88000000' },
  { componentId: 'mainLayout_hamburgerMenu_background', backgroundColor: '#FFFFFF' },
  { componentId: 'startOrder_loadingIndicator_color', iconColor: '#FDC710' },
  { componentId: 'startOrder_loadingText_text', textColor: '#757575' },
  { componentId: 'startOrder_heroTitle_text', textColor: '#212121' },
  { componentId: 'startOrder_heroSubtitle_gradientStart', gradientStartColor: '#014D7D', gradientEndColor: '#0C80C3' },
  { componentId: 'startOrder_heroSubtitle_gradientEnd', gradientStartColor: '#014D7D', gradientEndColor: '#0C80C3' },
  { componentId: 'startOrder_welcomeTitle_text', textColor: '#000000' },
  { componentId: 'startOrder_welcomeSubtitle_text', textColor: '#757575' },
  { componentId: 'startOrder_completeSetup_background', backgroundColor: '#FFF9E6' },
  { componentId: 'startOrder_completeSetup_border', borderColor: '#FFE082' },
  { componentId: 'startOrder_completeSetup_title_text', textColor: '#212121' },
  { componentId: 'startOrder_completeSetup_subtitle_text', textColor: '#757575' },
  { componentId: 'startOrder_completeSetup_indicator', backgroundColor: '#FFE082' },
  { componentId: 'startOrder_availablePlans_background', backgroundColor: '#F5F5F5' },
  { componentId: 'startOrder_availablePlans_title_text', textColor: '#000000' },
  { componentId: 'startOrder_recentOrders_background', backgroundColor: '#F5F5F5' },
  { componentId: 'startOrder_recentOrders_title_text', textColor: '#000000' },
  { componentId: 'startOrder_recentOrders_count_text', textColor: '#757575' },
  { componentId: 'startOrder_viewAllOrders_icon', iconColor: '#014D7D' },
  { componentId: 'startOrder_viewAllOrders_text', textColor: '#014D7D' },
  { componentId: 'startOrder_incompleteOrder_background', backgroundColor: '#FFFFFF' },
  { componentId: 'startOrder_incompleteOrder_border', borderColor: '#E0E0E0' },
  { componentId: 'startOrder_incompleteOrder_shadow', shadowColor: '#0D000000' },
  { componentId: 'startOrder_incompleteOrder_title_text', textColor: '#212121' },
  { componentId: 'startOrder_incompleteOrder_date_text', textColor: '#757575' },
  { componentId: 'startOrder_incompleteOrder_badge_background', backgroundColor: '#FFF3E0' },
  { componentId: 'startOrder_incompleteOrder_badge_text', textColor: '#FF9800' },
  { componentId: 'startOrder_incompleteOrder_infoIcon', iconColor: '#FDC710' },
  { componentId: 'startOrder_incompleteOrder_infoText', textColor: '#212121' },
  { componentId: 'startOrder_incompleteOrder_taskIcon', iconColor: '#FF9800' },
  { componentId: 'startOrder_incompleteOrder_taskText', textColor: '#212121' },
  { componentId: 'startOrder_incompleteOrder_taskMore_text', textColor: '#757575' },
  { componentId: 'startOrder_viewDetailsButton_background', backgroundColor: '#FDC710' },
  { componentId: 'startOrder_viewDetailsButton_text', textColor: '#FFFFFF' },
  { componentId: 'startOrder_viewDetailsButton_icon', iconColor: '#FFFFFF' },
  { componentId: 'startOrder_completeSetupButton_gradientStart', gradientStartColor: '#014D7D', gradientEndColor: '#0C80C3' },
  { componentId: 'startOrder_completeSetupButton_gradientEnd', gradientStartColor: '#014D7D', gradientEndColor: '#0C80C3' },
  { componentId: 'startOrder_completeSetupButton_text', textColor: '#FFFFFF' },
  { componentId: 'startOrder_planDetails_background', backgroundColor: '#00000000' },
  { componentId: 'startOrder_planDetails_barrier', shadowColor: '#8A000000' },
  { componentId: 'addressInfo_errorButton_background', backgroundColor: '#FF0000' },
  { componentId: 'profile_statusIndicator_active', iconColor: '#4CAF50' },
  { componentId: 'profile_statusIndicator_inactive', iconColor: '#FF0000' },
  { componentId: 'profile_notificationBadge_background', backgroundColor: '#FF9800' },
  { componentId: 'profile_errorButton_background', backgroundColor: '#FF0000' },
  { componentId: 'hamburgerMenu_logoutIcon', iconColor: '#FF0000' },
  { componentId: 'hamburgerMenu_logoutText', textColor: '#FF0000' },
  { componentId: 'international_container_background', backgroundColor: '#F5F5F5' },
  { componentId: 'international_container_border', borderColor: '#E0E0E0' },
  { componentId: 'international_button_background', backgroundColor: '#FFFFFF' },
  { componentId: 'international_button_text', textColor: '#757575' },
  { componentId: 'international_searchIcon', iconColor: '#757575' },
  { componentId: 'international_phoneIcon', iconColor: '#FFFFFF' },
  { componentId: 'international_phoneButton_gradientStart', gradientStartColor: '#014D7D', gradientEndColor: '#0C80C3' },
  { componentId: 'international_phoneButton_gradientEnd', gradientStartColor: '#014D7D', gradientEndColor: '#0C80C3' },
  { componentId: 'privacy_icon', iconColor: '#757575' },
  { componentId: 'terms_icon', iconColor: '#757575' },
  { componentId: 'previousOrders_scaffold_background', backgroundColor: '#FFFFFF' },
  { componentId: 'previousOrders_orderCard_border', borderColor: '#E0E0E0' },
  { componentId: 'plansView_modal_background', backgroundColor: '#00000000' },
  { componentId: 'plansView_modal_barrier', shadowColor: '#8A000000' },
  { componentId: 'plansView_modal_content_background', backgroundColor: '#FFFFFF' },
  { componentId: 'plansView_filterIcon', iconColor: '#757575' },
  { componentId: 'plansView_filterTitle_text', textColor: '#424242' },
  { componentId: 'plansView_filterSubtitle_text', textColor: '#757575' },
  { componentId: 'numberPorting_warning_background', backgroundColor: '#FF0000' },
  { componentId: 'porting_warning_background', backgroundColor: '#FF0000' },
  { componentId: 'deviceCompatibility_button_background', backgroundColor: '#00000000' },
  { componentId: 'deviceCompatibility_loadingIndicator', iconColor: '#FFFFFF' },
  { componentId: 'deviceCompatibility_icon', iconColor: '#FFFFFF' },
  { componentId: 'deviceCompatibility_text', textColor: '#FFFFFF' },
  { componentId: 'contactInfo_button_text', textColor: '#FFFFFF' },
  { componentId: 'numberSelection_radio_unselected', borderColor: '#E0E0E0' },
  { componentId: 'numberSelection_radio_selected', borderColor: '#E0E0E0' },
  { componentId: 'numberSelection_availabilityIcon_available', iconColor: '#4CAF50' },
  { componentId: 'numberSelection_availabilityIcon_unavailable', iconColor: '#FF0000' },
  { componentId: 'numberSelection_statusIcon_available', iconColor: '#4CAF50' },
  { componentId: 'numberSelection_statusIcon_unavailable', iconColor: '#FF0000' },
  { componentId: 'numberSelection_warningIcon', iconColor: '#FF9800' },
  { componentId: 'numberSelection_warningText', textColor: '#FF9800' },
  { componentId: 'numberSelection_selectedText', textColor: '#757575' },
  { componentId: 'numberSelection_button_text', textColor: '#FFFFFF' },
  // Missing component IDs from refactored code
  { componentId: 'screen-plans', backgroundColor: '#FFFFFF' },
  { componentId: 'screen-support', backgroundColor: '#FFFFFF' },
  { componentId: 'text-title', textColor: '#000000' },
  { componentId: 'text-body', textColor: '#757575' },
  { componentId: 'text-hint', textColor: '#9E9E9E' },
  { componentId: 'text-secondary', textColor: '#757575' },
  { componentId: 'button-primary', backgroundColor: '#808080', textColor: '#FFFFFF' },
  { componentId: 'button-danger', backgroundColor: '#FF0000', textColor: '#FFFFFF' },
  { componentId: 'button-text', textColor: '#FFFFFF' },
  { componentId: 'icon-secondary', iconColor: '#757575' },
  { componentId: 'link-primary', textColor: '#014D7D' },
  { componentId: 'tab-container', backgroundColor: '#E0E0E0' },
];

// Get environment variables or command line arguments
function getConfig() {
  const args = process.argv.slice(2);
  let spaceId = process.env.CONTENTFUL_SPACE_ID;
  let token = process.env.CONTENTFUL_MANAGEMENT_TOKEN;

  args.forEach(arg => {
    if (arg.startsWith('--space-id=')) {
      spaceId = arg.split('=')[1];
    } else if (arg.startsWith('--token=')) {
      token = arg.split('=')[1];
    }
  });

  if (!spaceId || !token) {
    console.error('❌ Error: Missing required configuration');
    console.error('');
    console.error('Please provide:');
    console.error('  1. Environment variables:');
    console.error('     - CONTENTFUL_SPACE_ID');
    console.error('     - CONTENTFUL_MANAGEMENT_TOKEN');
    console.error('');
    console.error('  2. Or command line arguments:');
    console.error('     --space-id=YOUR_SPACE_ID --token=YOUR_TOKEN');
    console.error('');
    process.exit(1);
  }

  return { spaceId, token };
}

async function importComponentColors() {
  const { spaceId, token } = getConfig();

  console.log('🚀 Starting Component Colors Import...');
  console.log(`   Space ID: ${spaceId}`);
  console.log('');

  try {
    // Initialize Contentful client
    const client = contentful.createClient({
      accessToken: token,
    });

    // Get space and environment
    const space = await client.getSpace(spaceId);
    const environment = await space.getEnvironment('master');

    console.log('✅ Connected to Contentful');
    console.log('');

    let created = 0;
    let updated = 0;
    let errors = 0;

    // Import each component color
    for (const colorData of componentColors) {
      try {
        const { componentId, ...colorFields } = colorData;

        // Prepare fields for Contentful (with locale)
        const fields = {
          componentId: { 'en-US': componentId },
        };

        // Add color fields if they exist
        if (colorData.backgroundColor) {
          fields.backgroundColor = { 'en-US': colorData.backgroundColor };
        }
        if (colorData.textColor) {
          fields.textColor = { 'en-US': colorData.textColor };
        }
        if (colorData.borderColor) {
          fields.borderColor = { 'en-US': colorData.borderColor };
        }
        if (colorData.iconColor) {
          fields.iconColor = { 'en-US': colorData.iconColor };
        }
        if (colorData.shadowColor) {
          fields.shadowColor = { 'en-US': colorData.shadowColor };
        }
        if (colorData.gradientStartColor) {
          fields.gradientStartColor = { 'en-US': colorData.gradientStartColor };
        }
        if (colorData.gradientEndColor) {
          fields.gradientEndColor = { 'en-US': colorData.gradientEndColor };
        }

        // Try to get existing entry
        let entry;
        try {
          const entries = await environment.getEntries({
            content_type: 'componentColor',
            'fields.componentId[en-US]': componentId,
            limit: 1,
          });

          if (entries.items.length > 0) {
            entry = entries.items[0];
            // Update existing entry
            Object.keys(fields).forEach(fieldKey => {
              entry.fields[fieldKey] = fields[fieldKey];
            });
            entry = await entry.update();
            await entry.publish();
            updated++;
            console.log(`   ✅ Updated: ${componentId}`);
          } else {
            throw new Error('Entry not found');
          }
        } catch (error) {
          // Create new entry
          entry = await environment.createEntry('componentColor', {
            fields: fields,
          });
          await entry.publish();
          created++;
          console.log(`   ✨ Created: ${componentId}`);
        }
      } catch (error) {
        errors++;
        console.error(`   ❌ Error with ${colorData.componentId}: ${error.message}`);
      }
    }

    console.log('');
    console.log('📊 Import Summary:');
    console.log(`   ✅ Created: ${created}`);
    console.log(`   🔄 Updated: ${updated}`);
    console.log(`   ❌ Errors: ${errors}`);
    console.log(`   📦 Total: ${componentColors.length}`);
    console.log('');
    console.log('🎉 Import completed!');

  } catch (error) {
    console.error('');
    console.error('❌ Import failed:');
    console.error(error.message);
    console.error('');
    process.exit(1);
  }
}

// Run the import
importComponentColors();

