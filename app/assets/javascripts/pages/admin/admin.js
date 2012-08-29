
/* Extend jQuery with functions for PUT and DELETE requests. */

function _ajax_request(url, data, callback, type, method) {
    if (jQuery.isFunction(data)) {
        callback = data;
        data = {};
    }
    return jQuery.ajax({
        type: method,
        url: url,
        data: data,
        success: callback,
        dataType: type
        });
}

jQuery.extend({
    put: function(url, data, callback, type) {
        return _ajax_request(url, data, callback, type, 'PUT');
    },
    delete_: function(url, data, callback, type) {
        return _ajax_request(url, data, callback, type, 'DELETE');
    }
});

(function($){
	$.BehaviorDetector = {
		register: function(selector, behavior){
			if(!$(this).data('behaviors')){
				$(this).data('behaviors', {});
			}
			var behaviors = $(this).data('behaviors');
			if(!behaviors[selector]){
				behaviors[selector] = [];
			}
			behaviors[selector].push(behavior);
		},
		run: function(){
			if($(this).data('behaviors')){
				for(var selector in $(this).data('behaviors')){
					for(var a = 0; a < $(this).data('behaviors')[selector].length; a++){
						var behavior = $(this).data('behaviors')[selector][a];
						$(selector).filter(function(){
							return !$(this).data('appliedBehaviors') || $.inArray(behavior, $(this).data('appliedBehaviors'));
						}).each(function(){
							$(this).each(behavior);
							if(!$(this).data('appliedBehaviors')){
								$(this).data('appliedBehaviors', []);
							}
							$(this).data('appliedBehaviors').push(behavior);
							return this
						});
					}
				}
			}
		}
	};
	$.fn.onDetect = function(behavior){
		$.BehaviorDetector.register(this.selector, behavior);
		$.BehaviorDetector.run();
		return this;
	};
	$(document).ready(function(){
		$.BehaviorDetector.run();
	});
	$(document.body).bind('modified', function(){
		$.BehaviorDetector.run();
	});
})(jQuery);


var Modal = {
	container: false,
	makeContainer: function(){
		var modal = this;
		if(!this.container){
			jQuery(document.body).append('<div id="modal_container"/>');
			this.container = jQuery('#modal_container').get(0);
			jQuery(this.container).hide();
			jQuery(window).scroll(function(){
				modal.position();
			});
			jQuery(window).resize(function(){
				modal.position();
			});
		}
	},
	clear: function(){
		jQuery(this.container).fadeOut(150,function(){
			jQuery(this).html();
			jQuery('#modalOverlay').fadeOut(50);
		});
	},
	draw: function(options){
		var modal = this;
		this.makeContainer();
		jQuery(this.container).show();
		jQuery(this.container).html('<div class="container">'+options.text+'</div>');
		this.position();
		jQuery(document.body).append('<div id="modalOverlay"/>');
		jQuery(document.body).trigger('modified');
		jQuery('#modalOverlay').show().click(function(){Modal.clear();}).css({
			position: 'absolute', top: 0, left: 0, width: jQuery(document).width()+'px', height: jQuery(document).height()+'px', 'z-index': 19,
			'background-color': '#000000', opacity: 0
		}).animate({
		 	opacity: 0.6
		}, 100);
	},
	position: function(){
		var width  = jQuery(this.container).width();
		var height = jQuery(this.container).height();
		var scrollTop = jQuery(window).scrollTop();
		var viewportWidth = window.innerWidth ? window.innerWidth : jQuery(window).width();
		var viewportHeight = window.innerHeight ? window.innerHeight : jQuery(window).height();
		var left   = Math.round(viewportWidth / 2) - (width / 2);
		var top    = (Math.round(viewportHeight / 2) - (height / 2)) + scrollTop;
		if(top < 5) { top = 5; }
		if(left < 5) { left = 5; }
		jQuery('#modalOverlay').css({
			top: 0, left: 0, width: jQuery(document).width()+'px', height: jQuery(document).height()+'px'
		});
		jQuery(this.container).css('left', left).css('top', top);
	},
	alert: function(string){
		this.draw({text: string});
	},
	show: function(string){
		this.draw({text: string});
	},
	showMap: function(string){
		this.draw({text: string});
	}
}

jQuery.fn.centerOnScreen = function(){
    var win_width      = jQuery(window).width();
    var scrollToLeft   = jQuery(window).scrollLeft();
    var win_height     = jQuery(window).height();
    var scrollToBottom = jQuery(window).scrollTop();
	var box_width = 200;
	var box_height = 200;

	this.css('position', 'absolute');
	this.css('z-index', (1000+(Math.round(Math.random() * 5000))));

	var x = ((jQuery(window).width() / 2) - (this.width() / 2)) + jQuery(window).scrollLeft();
	var y  = ((jQuery(window).height() / 2) - (this.height() / 2)) + jQuery(window).scrollTop();
	if(x < 0) { x = 0; }; if(y < 0) { y = 0; }

	this.css({ left: x+"px", top: y+"px" });

	return this;
}


function jRichTextArea(textArea, options){
	this.textArea = textArea;

	// Default options
	settings = jQuery.extend({
	     className: "richTextToolbar"
	}, options);

	this.toolbar = {
		settings : settings,
		textArea : textArea,
		listElement : false,
		buttons : new Array(),
		addButton : function(name, callback, options) {
			// Default options
			settings = jQuery.extend({
			     className: name.replace(/[\s]+/, '')+"Button"
			}, options);
			var li = document.createElement("li");
			var a = document.createElement("a");
			a.title = name;
			a.textArea = this.textArea;
			//callback.this = this;
			jQuery(a).mousedown(callback);
			jQuery(a).addClass(settings.className);
			jQuery(li).append(a).appendTo(this.listElement);
			this.buttons.push(li);
			return this;
		},
		create : function() {
			if(!this.listElement) {
				this.listElement = document.createElement("ul");
				jQuery(this.listElement).addClass(this.settings.className);
				jQuery(this.listElement).insertBefore(this.textArea);
			}
		}
	}

	this.textArea.selectedText = function() {
		return jQuery(this).getSelection().text;
	}
	this.textArea.replaceSelection = function(replacement) {
		return jQuery(this).replaceSelection(replacement);
	}
	this.textArea.wrapSelection = function() {
		var prepend = arguments[0];
		var append = (arguments.length > 1) ? arguments[1] : prepend
		var selectedText = this.selectedText();
		var trailingSpace = selectedText.match(/(\s)*$/)[0];
		selectedText = selectedText.replace(/(\s)*$/, '');
		return this.replaceSelection(prepend + selectedText + append + trailingSpace);
	}

	// Delegates
	this.textArea.toolbar = this.toolbar;
	this.toolbar.create();
}

function EditableImage(link, options){

	// Default options
	settings = jQuery.extend({
		resourceURL: link.href,
		width: 800
	}, options);

	this.editableImage = {
		settings : settings,
		link : link,
		linkedImage : jQuery(link).children('img')[0],
		resourceURL : settings.resourceURL,
		editorDialog : false,
		imageData : false,
		previewURL : false,
		cropStartX : false,
		cropStartY : false,
		cropWidth : false,
		cropHeight : false,
		getScale : function() {
			return (this.settings.width / this.imageData.original_width);
		},
		openEditor : function() {
			// Dim the screen and create the loading dialog
			jQuery.dimScreen(200, 0.90);
			jQuery('body').append("<div id=\"modalLoadingNotice\"><img src=\"/assets/pages/admin/loading-modal.gif\" /> Loading image editor&hellip;</div>");
			jQuery('#modalLoadingNotice').centerOnScreen().hide().fadeIn(200);

			// Create the container
			jQuery('#editableImageEditor').remove();
			jQuery('body').append("<div id=\"editableImageEditor\" class=\"modalWindow\"></div>");

			// Load data
			var binding = this;
			if(!this.imageData){
				jQuery.getJSON(this.resourceURL+".js", function(json){
					binding.imageData = json;
					binding.populateEditor();
				});
			} else {
				this.populateEditor();
			}
		},
		populateEditor : function() {
			jQuery('#editableImageEditor')
				.empty()
				.append("<img id=\"editableImageEditorImage\" />")
				.append("<div id=\"editableImageEditorControls\" class=\"controls\" />")
				.hide();
			jQuery('#editableImageEditorControls')
				.append("<input type=\"button\" id=\"editableImageEditorSubmit\" value=\"Save\" />")
				.append("<input type=\"button\" id=\"editableImageEditorClose\" value=\"Cancel\" />")

			this.previewURL = this.linkedImage.src.replace(this.linkedImage.src.match(/([\d]*x[\d]*)/)[1], 'original/'+this.settings.width+'x');
			this.previewURL = this.previewURL.replace(/([\?\d])*$/, '');

			var binding = this;
			jQuery('#editableImageEditorImage').each(function(){
				this.src = binding.previewURL;
			});
			jQuery('#editableImageEditorSubmit').click(function(){
				binding.submit();
			});
			jQuery('#editableImageEditorClose').click(function(){
				binding.closeEditor();
			});

			var onCrop = function(coords) {
				binding.cropStartX = coords.x;
				binding.cropStartY = coords.y;
				binding.cropWidth = coords.w;
				binding.cropHeight = coords.h;
			}
			jQuery('#editableImageEditorImage').load(function(){
				jQuery('#modalLoadingNotice').fadeOut(100);
				jQuery('#editableImageEditor').show().centerOnScreen();
				var jCropOptions = {
					onChange: onCrop,
					onSelect: onCrop
				}
				var imageData = binding.imageData;
				if(imageData.cropped) {
					var crop_start_x = Math.round(imageData.crop_start_x * binding.getScale());
					var crop_start_y = Math.round(imageData.crop_start_y * binding.getScale());
					var crop_end_x = crop_start_x + Math.round(imageData.crop_width * binding.getScale());
					var crop_end_y = crop_start_y + Math.round(imageData.crop_height * binding.getScale());
					jCropOptions['setSelect'] = [crop_start_x, crop_start_y, crop_end_x, crop_end_y];
				}
				// console.log(jCropOptions);
				jQuery('#editableImageEditorImage').Jcrop(jCropOptions);
			});

		},
		closeEditor : function() {
			jQuery('#modalLoadingNotice').remove();
			jQuery('#editableImageEditor').remove();
			this.imageData = false;
			jQuery.dimScreenStop();
		},
		refreshLinkedImage : function(size) {
			var imageUrl = this.linkedImage.src.replace(/\?.*$/, '') + '?' + (new Date().getTime());
			this.linkedImage.src = imageUrl;
			/*
			var newURL = this.linkedImage.src.toString();
			newURL = newURL.replace(/\/[\d]+x[\d]+\//, '/'+size+'/'); // temporary hack, fix to use rel="" dimensions
			newURL = newURL+"?"+Math.round(Math.random() * 65535);
			this.linkedImage.src = newURL;
			size = size.split("x",2); newWidth = size[0]; newHeight = size[1];
			this.linkedImage.width = newWidth;
			this.linkedImage.height = newHeight;
			*/
		},
		submit : function() {
			var cropped = (!this.cropWidth || !this.cropHeight) ? 0 : 1;
			var crop_start = false;
			var crop_size  = false;
			var put_options = false;
			if(cropped) {
				crop_size = Math.floor(this.cropWidth/this.getScale())+"x"+Math.floor(this.cropHeight/this.getScale());
				crop_start = Math.floor(this.cropStartX/this.getScale())+"x"+Math.floor(this.cropStartY/this.getScale());
				put_options = { 'image[cropped]': cropped, 'image[crop_size]': crop_size, 'image[crop_start]': crop_start }
			} else {
				put_options = { 'image[cropped]': cropped }
			}
			var binding = this;
			jQuery.put(this.resourceURL + ".json", put_options, function(json) {
				binding.refreshLinkedImage(crop_size);
				binding.closeEditor();
			})
		}
	}

	// Apply onClick behaviour
	link.editableImage = this.editableImage;
	jQuery(link).click(function(){
		this.editableImage.openEditor();
		return false;
	});

	//this.editableImage.openEditor(); // debug
}

var PagesAdmin = {

	controller : false,
	action : false,

	sniffBrowser : function() {
		if(navigator) {
			jQuery.each(Array("WebKit","Gecko","Firefox"), function(){
				if( navigator.userAgent.match( new RegExp(this+"\\/[\\d]+", 'i'))) {
					jQuery(document.body).addClass(this.toLowerCase());
				}
			});
			if(navigator.userAgent.match("MSIE")) {
				jQuery(document.body).addClass('msie')
			};
			if( navigator.userAgent.match("MSIE 7") ) {
				jQuery(document.body).addClass('msie7');
			}
		}
	},

	applyTextAreas : function() {
		jQuery('textarea.rich').each(function(){
			var ta = new jRichTextArea(this);

			// Add buttons to the field
			ta.toolbar
				// Bold
				.addButton("Bold", function(){ this.textArea.wrapSelection('*'); })
				// Italic
				.addButton("Italics", function(){ this.textArea.wrapSelection('_'); })
				// Headings
				.addButton("Heading 2", function(){ this.textArea.wrapSelection('h2. ',''); })
				.addButton("Heading 3", function(){ this.textArea.wrapSelection('h3. ',''); })
				.addButton("Heading 4", function(){ this.textArea.wrapSelection('h4. ',''); })
				// Links
				.addButton("Link", function() {
			    var selection = this.textArea.selectedText();
			    if (selection === '') {
			    	selection = prompt('Link text', '');
			    }
			    var response = prompt('Enter link URL', 'http://');
			    if (response) {
				    this.textArea.replaceSelection(
							'"' + (selection === '' ? "Link text" : selection) + '":' +
							(response === '' ? 'http://link_url/' : response).replace(/^(?!(f|ht)tps?:\/\/)/,'http://')
						);
			    }
				})
				// Email links
				.addButton("Email", function() {
			    var selection = this.textArea.selectedText();
			    var response = prompt('Enter mail address','');
			    if (response) {
				    this.textArea.replaceSelection(
							'"' + (selection === '' ? response : selection) + '":mailto:' +
							(response == '' ? '' : response)
						);
			    }
				})
				// Image tag
				.addButton("Image", function(){
				    var selection = this.textArea.selectedText();
					if( selection == '') {
					    var response = prompt('Enter image URL','');
					    if(response == null)
					        return;
						this.textArea.replaceSelection('!'+response+'!');
					} else {
						this.textArea.replaceSelection('!'+selection+'!');
					}
				})
			;
		});
	},

	applyEditableImages : function() {
		jQuery('a.editableImage').each(function(){
			new EditableImage(this);
		});
	},

	applyStyles : function() {
		// Detect the sidebar and add the appropriate class to the document element.
		if(jQuery('#sidebar').length > 0){
			jQuery(document.body).addClass('with_sidebar');
		}

		// Add input_$type class to inputs.
		jQuery('input').each(function(i){jQuery(this).addClass("input_"+this.type);});

		// Inject buttons with <div class="inner">
		jQuery('button').wrapInner('<div class="inner"></div>');

	},

	init : function() {
		PagesAdmin.sniffBrowser();
		PagesAdmin.applyStyles();
		PagesAdmin.applyEditableImages();
		PagesAdmin.applyTextAreas();
		if(PagesAdmin.contentTabs) {
			PagesAdmin.contentTabs.init();
		}

		// Call the controller action
		if(PagesAdmin.controller) {
			if(PagesAdmin.controller.init){
				PagesAdmin.controller.init();
			}
			if(PagesAdmin.action && PagesAdmin.controller[PagesAdmin.action+"_action"]) {
				PagesAdmin.controller[PagesAdmin.action+"_action"]();
			}
		}
	}
}
var Admin = PagesAdmin;

PagesAdmin.contentTabs = {

	tabs : new Array(),
	ids : new Array(),

	show : function(tab_id) {
		var tabs = PagesAdmin.contentTabs.tabs;
		var tab = tabs[tab_id];
		if(tab) {
			jQuery.each(PagesAdmin.contentTabs.ids, function(i){
				if(tabs[this]) {
					jQuery(tabs[this]).hide();
				} else {
					// console.log("Could not hide tab: "+this);
				}
				jQuery("#content-tab-link-"+this).removeClass('current');
			});
			jQuery(tab).show();
			jQuery("#content-tab-link-"+tab_id).addClass('current');
		}
	},

	showFromURL : function(url) {
		var tab_expression = /#(.*)$/
		if(url.toString().match(tab_expression)){
			var tab_id = url.toString().match(tab_expression)[1];
			if(PagesAdmin.contentTabs.tabs[tab_id]){
				PagesAdmin.contentTabs.show(tab_id);
			}
		}
	},

	enable : function(tab_ids) {
		//PagesAdmin.contentTabs.tabs = new Array();
		var tabs = PagesAdmin.contentTabs.tabs;
		PagesAdmin.contentTabs.ids = tab_ids;
		jQuery.each(tab_ids, function(i) {
			var tab_id = this;
			jQuery("#content-tab-"+this).each(function(i){
				this.tab_id = tab_id;
				tabs[tab_id] = this;
			});
		});
		PagesAdmin.contentTabs.show(tab_ids[0]);
		PagesAdmin.contentTabs.showFromURL(document.location);
	},

	init : function() {
		(function ($) {
			if(jQuery('#content-tabs').length > 0) {
				jQuery('#content-tabs a').each(function(){
					jQuery(this).click(function(){
						PagesAdmin.contentTabs.showFromURL(this.href);
					});
				});
			}
			window.showContentTab = PagesAdmin.contentTabs.show;
		})(jQuery);
	}
}

jQuery(PagesAdmin.init);