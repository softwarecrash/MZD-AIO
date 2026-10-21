	( function() {

window.opera.addEventListener( 'AfterEvent.load', function (e) {
	/* adding div and text at the top of the page */
	if(!document.getElementById('cfpsDiv')) {
		var docBody = document.getElementsByTagName('body')[0];
		if (docBody) {
			var text = document.createElement("span");
			text.id = 'cfpsText';
			text.innerText="(unknown)";
			text.setAttribute('style','color:red');

			var div = document.createElement("div");
			div.id = 'cfpsDiv';
			div.setAttribute('style','right:10px; bottom:10px; background-color:yellow; height:20px; z-index:20000; position:absolute; color:red; line-height:20px; padding:0 5px;');
			div.innerText="FPS counter: ";	
		
			div.appendChild(text);

			if(docBody.firstChild) {
				docBody.insertBefore(div, docBody.firstChild);
			} else {
				docBody.appendChild(div);
			}
			
			setInterval(function() {
				if(document.getElementById('cfpsText')) { 
					var fpsStr = opera.sendPlatformMessage('stopFPS').toString();
					fpsStr = fpsStr.substr(0, (fpsStr.indexOf('.') + 2));
					document.getElementById('cfpsText').textContent = fpsStr; 
					opera.sendPlatformMessage('startFPS'); 
				}
			}, 1000);
		}
	}

}, false );


})();
