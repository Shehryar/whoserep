const CancelSubmitScrollView = require('./cancel_submit_scroll_view');
const Components = require('../components');
const Templates = require('../templates');

module.exports = function(data) {
	// Properties
	data.root = data.root || {};
	data.root.scrollContent = data.root.scrollContent || {};

	data.root.scrollContent.title = 'Feedback Survey';
	data.root.scrollContent.bodyText = 'Please take a moment to fill out the survey. It should only take about 1 minute to complete. Your responses will help us better serve your needs. Your individual survey answers may be shared internally for service improvement purposes.\n\nThank you!';

	var items = [];
	
	const defaultPadding = '0 24';

	function addSeparator(marginTop) {
		items.push(new Components.Separator({
			style: {
				align: 'fill',
				marginTop: marginTop || 32,
				marginBottom: 32
			}
		}));
	}

	function addSectionHeader(title, marginTop) {
		if (title) {
			items.push(new Components.Label({
				text: title,
				style: {
					textType: 'header2',
					padding: defaultPadding,
					marginBottom: 32,
					marginTop: marginTop || 0
				}
			}));
		}
	}

	function addBodyText(text, center) {
		if (text) {
			let style = {
				textType: 'body',
				padding: defaultPadding,
				marginBottom: 16
			};
			if (center) {
				style.align = 'center';
				style.textAlign = 'center';
			}

			items.push(new Components.Label({
				text: text,
				style: style
			}));
		}
	}

	function addTextArea(name) {
		items.push(new Components.TextArea({
			name: name,
			placeholder: 'Leave a comment (optional)',
			style: {
				align: 'fill',
				padding: defaultPadding
			}
		}));
	}

	addSectionHeader('Feedback Survey', 32);
	addBodyText('Please take a moment to fill out the survey. It should only take about 1 minute to complete. Your responses will help us better serve your needs. Your individual survey answers may be shared internally for service improvement purposes.');
	addBodyText('Thank you!');


	addSeparator(16);
	addSectionHeader('How likely are you to recommend Boost to friends or family?');
	items.push(new Components.Slider({
		name: 'rating',
		min: 0,
		max: 10,
		label: new Components.Label({
			text: ' ',
			style: {
				padding: "16 20",
				textType: 'header2',
				backgroundColor: '#8b92a3',
				color: '#ffffff',
				marginBottom: 24,
				align: 'center',
				cornerRadius: 8
			}
		}),
		style: {
			padding: defaultPadding,
			align: 'fill',
			marginBottom: 32
		}
	}));
	addTextArea('ratingComment')

	addSeparator();
	addSectionHeader('Did this chat increase, decrease or not change your likelihood to recommend Boost?');
	items.push(new Templates.BasicRadioButtonsList({
		name: 'recommendationChange',
		radioButtons: [
			{
				value: 'increase',
				bodyText: 'Increase'
			},
			{
				value: 'decrease',
				bodyText: 'Decrease'
			},
			{
				value: 'noChange',
				bodyText: 'Not Change'
			}
		], 
		style: {
			padding: defaultPadding
		}
	}));

	addSeparator();
	addSectionHeader('Based on your answer to the previous question, could you explain why?');
	addTextArea('recommendationComment');

	addSeparator();	
	addSectionHeader('What could we do to better serve you?');
	addTextArea('improvementComment');

	addSeparator();	
	addSectionHeader('Will you be calling customer care to follow up on this particular issue?');
	items.push(new Templates.BasicRadioButtonsList({
		name: 'willCallCustomerCare',
		radioButtons: [
			{
				value: true,
				bodyText: 'I will be calling customer care.'
			},
			{
				value: false,
				bodyText: 'I will not be calling customer care.'
			}
		], 
		style: {
			padding: defaultPadding
		}
	}));
	
	addSeparator();	
	addBodyText('Thank you very much for your time.', true);
	addBodyText('We know you have several choices for a telecommunications provider and we appreciate your business.', true);
	addBodyText('Thank you for choosing Boost.', true);


	data.root.scrollContent = new Components.StackView({
		items: items,
		style: {
			paddingBottom: 32
		}
	});

	CancelSubmitScrollView.call(this, data);
};
