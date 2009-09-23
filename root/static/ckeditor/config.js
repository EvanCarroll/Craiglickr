/*
Copyright (c) 2003-2009, CKSource - Frederico Knabben. All rights reserved.
For licensing, see LICENSE.html or http://ckeditor.com/license
*/

CKEDITOR.editorConfig = function( config )
{
	// Define changes to default configuration here. For example:
	// config.language = 'fr';
	// config.uiColor = '#AADC6E';
	config.toolbarCanCollapse = false;
	config.fullPage = true;
	config.resize_enabled = false;
	config.height = '400px';
};
	
CKEDITOR.config.toolbar_Full = [
	['Link', 'Unlink', '-', 'Image', '-', 'JustifyLeft', 'JustifyCenter', 'JustifyRight']
	, ['Bold', 'Italic', 'Underline', '-', 'FontStyle', 'FontFormat', 'Font', 'FontSize', '-', 'BGColor', 'TextColor']
];

