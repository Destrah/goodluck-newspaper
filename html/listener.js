let columns = [];
let up = false;
let previousValue = 0

$(function(){
	window.onload = (e) => {
		window.addEventListener('message', (event) => {
			var item = event.data;
			if (item !== undefined && item.type === "ui") {
				$(".articleManager").css("display", "none")
				$("#container").fadeIn(100)
				if (item.display === true) {
					if (item.liveInfo.isLive) {
						$("#liveNews").css("display", "block")
						$("#liveNews").html(`
								<div class="head">
									<div class="headerobjectswrapper">
										<header class="newspaper-header">LIVE COVERAGE</header>
									</div>
									<div class="subhead date">Los Santos, SA - Date</div>
								</div>
								<div class="live">
									<div id="liveStream">
										<iframe id="liveIFrame" style="pointer-events: all;" src="https://www.youtube.com/embed/${item.liveInfo.liveID}?si=&autoplay=1&vq=small" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen>
										</iframe>
									</div>
								</div>
								<hr style="width: 100%; height: 2px; color: black; border-width: 0; background-color: black; padding: 0; margin: 0;">
							`)
					} else {
						if ($("#liveNews").css("display") == "block") {
							$( "iframe" ).remove( "#liveIFrame" );
							$("#liveNews").css("display", "none")
						}
					}
					const weekday = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"];
					const month = ["January","February","March","April","May","June","July","August","September","October","November","December"];
					let date = new Date();
					let formatted = weekday[date.getDay()] + " " + month[date.getMonth()] + " " + date.getDate() + ", " + date.getFullYear();
					let divs = document.getElementsByClassName("date");
					[].slice.call( divs ).forEach(function ( div ) {
						div.innerHTML = `Los Santos, SA - ${formatted}`;
					});
					internationalNumberFormat = new Intl.NumberFormat('en-US')
					let bjwinner = document.getElementsByClassName("bjwinner");
					[].slice.call( bjwinner ).forEach(function ( div ) {
						div.innerHTML = `Lucky Number:</br>${item.secretInfo.digit} (${item.secretInfo.digitNumber}) (${item.secretInfo.codeNumber})</br>Updates every 15 minutes`;
					});
					let motd = document.getElementById("motd"); 
					let motdtwo = document.getElementById("motd2"); 
					motd.innerHTML = item.motd;
					motdtwo.innerHTML = item.motd;
					for (let i = 0; i < item.columns.length; i++) {
						let headlineclass = "headline hl1";
						let subheadlineclass = "headline hl6";
						if (item.columns[i].titletype == 1) {
							headlineclass = "headline hl1";
						} else if (item.columns[i].titletype == 2) {
							headlineclass = "headline hl3";
						} else if (item.columns[i].titletype == 3) {
							headlineclass = "headline hl5";
						} else if (item.columns[i].titletype == 4) {
							headlineclass = "headline hl7";
						} else if (item.columns[i].titletype == 5) {
							headlineclass = "headline hl9";
						}
						if (item.columns[i].subtitletype == 1) {
							subheadlineclass = "headline hl2";
						} else if (item.columns[i].subtitletype == 2) {
							subheadlineclass = "headline hl4";
						} else if (item.columns[i].subtitletype == 3) {
							subheadlineclass = "headline hl6";
						} else if (item.columns[i].subtitletype == 4) {
							subheadlineclass = "headline hl8";
						} else if (item.columns[i].subtitletype == 5) {
							subheadlineclass = "headline hl10";
						}
						document.getElementById("column"+(i+1)).innerHTML = 	`
						<div class="head">
							<span class="${headlineclass}">${item.columns[i].title}</span>
							<p>
								<span class="${subheadlineclass}">
									${item.columns[i].subtitle}
								</span>
							</p>
						</div>`
						
						let sections = item.columns[i].body.split("|");
						for (let j = 0; j < sections.length; j++) {
							let formattedForImages = sections[j];
							if (formattedForImages != "") {
								//while (formattedForImages.includes("<img>")) {
								//
								//}
								let test = formattedForImages.match(/<img>(.*?)<\/img>/g)
								if (test != undefined) {
									let imageLinks = formattedForImages.match(/<img>(.*?)<\/img>/g).map(function(val){
										return val.replace(/<\/?img>/g,'');
									});
									let captions = null;
									if (formattedForImages.match(/<caption>(.*?)<\/caption>/g) != undefined) {
										captions = formattedForImages.match(/<caption>(.*?)<\/caption>/g).map(function(val){
												return val.replace(/<\/?caption>/g,'');
										});
									}
									for (let k = 0; k < imageLinks.length; k++) {
										if (captions != null) {
											formattedForImages = formattedForImages.replace(/<img>[\s\S]*?<\/img>/, 
											`<figure class=\"figure\">
												<img class="media" src="${imageLinks[k]}" alt=\"\">
												<figcaption class=\"figcaption\">${captions[k]}</figcaption>
											</figure>`)
											formattedForImages = formattedForImages.replace(/<caption>[\s\S]*?<\/caption>/, "")
										} else {
											formattedForImages = formattedForImages.replace(/<img>[\s\S]*?<\/img>/, 
											`<figure class=\"figure\">
												<img class="media" src=\"${imageLinks[k]}\" alt=\"\">
											</figure>`)
										}
									}
								}
								let advert = formattedForImages.match(/<ad>(.*?)<\/ad>/g)
								if (advert != undefined) {
									let imageLinks = formattedForImages.match(/<ad>(.*?)<\/ad>/g).map(function(val){
										return val.replace(/<\/?ad>/g,'');
									});
									let captions = null;
									if (formattedForImages.match(/<caption>(.*?)<\/caption>/g) != undefined) {
										captions = formattedForImages.match(/<caption>(.*?)<\/caption>/g).map(function(val){
												return val.replace(/<\/?caption>/g,'');
										});
									}
									for (let k = 0; k < imageLinks.length; k++) {
										if (captions != null) {
											formattedForImages = formattedForImages.replace(/<ad>[\s\S]*?<\/ad>/, 
											`<div class="advert-${i}" style="width: 95%; position: absolute; left: 0; bottom: 0px; padding-top: calc(50%); padding-left: calc(2.5%); padding-right: calc(2.5%);">
												<hr style="height: 2px; background: black;"/>
												<figure class=\"figure\>
													<img src="${imageLinks[k]}" alt=\"\">
													<figcaption class=\"figcaption\">${captions[k]}</figcaption>
												</figure>
											</div>`)
											formattedForImages = formattedForImages.replace(/<caption>[\s\S]*?<\/caption>/, "")
										} else {
											formattedForImages = formattedForImages.replace(/<ad>[\s\S]*?<\/ad>/, 
											`<div class="advert-${i}" style="width: 95%; position: absolute; left: 0; bottom: 0px; padding-top: calc(50%); padding-left: calc(2.5%); padding-right: calc(2.5%);">
												<hr style="height: 2px; background: black;"/>
												<figure class=\"figure\">
													<img src=\"${imageLinks[k]}\" alt=\"\">
												</figure>
											</div>`)
										}
									}
								}
								document.getElementById("column"+(i+1)).innerHTML += `
								<p>
									${formattedForImages}
								</p>`;
							}
						}
					}
					for (let i = 0; i < item.arrests.length; i++) {
						let mugShot = "mugshot.jpg";
						if (item.arrests[i].picture != "img/female.png" && item.arrests[i].picture != "img/male.png" && item.arrests[i].picture != null) {
							mugShot = item.arrests[i].picture;
						}
						document.getElementById("arrest"+(i+1)).innerHTML = 	`
						<div class="head">
							<span class="headline hl1" style="font-size: 24;">${item.arrests[i].name}'s Sentencing</span>
						</div>
						<figure class="figure">
							<img class="media" src="${mugShot}" alt="mugshot.jpg">
							<figcaption class=\"figcaption\">Mug Shot</figcaption>
						</figure>`;
						let date = new Date(Date.parse(item.arrests[i].date));
						let formatted = weekday[date.getDay()] + " " + month[date.getMonth()] + " " + date.getDate() + ", " + date.getFullYear();
						let time = format_two_digits(date.getHours()) + ":" + format_two_digits(date.getMinutes()) + ":" + format_two_digits(date.getSeconds());
						if (item.arrests[i].issuedjail) {
							document.getElementById("arrest"+(i+1)).innerHTML += `
							<p>
								${item.arrests[i].name} was sentenced to jail for up to ${item.arrests[i].issuedjail} month(s) on ${formatted} ${time} PST
							</p>`
						} else {
							document.getElementById("arrest"+(i+1)).innerHTML += `
							<p>
								${item.arrests[i].name} was sentenced to community service for ${item.arrests[i].issuedcommserv} hours(s) on ${formatted} ${time} PST
							</p>`
						}
						document.getElementById("arrest"+(i+1)).innerHTML += `
							Charges:</br>`
						let charges = item.arrests[i].charges
						let pos = 0;
						for (var key in charges) {
							document.getElementById("arrest"+(i+1)).innerHTML += `${key} x${charges[key]}`
							if (pos != Object.keys(charges).length) {
								document.getElementById("arrest"+(i+1)).innerHTML += `</br>`
							}
						}
						document.getElementById("arrest"+(i+1)).innerHTML += `
						</br><p>
							Arresting Officer: ${item.arrests[i].author}
						</p>`
					}
					for (let i = 0; i < 5; i++) {
						if (i < item.warrants.length) {
							let mugShot = "mugshot.jpg";
							if (item.warrants[i].picture != "img/female.png" && item.warrants[i].picture != "img/male.png" && item.warrants[i].picture != null) {
								mugShot = item.warrants[i].picture;
							}
							document.getElementById("warrant"+(i+1)).innerHTML = 	`
							<div class="head">
								<span class="headline hl1" style="font-size: 24;">${item.warrants[i].name}'s Active Warrant</span>
							</div>
							<figure class="figure">
								<img class="media" src="${mugShot}" alt="mugshot.jpg">
								<figcaption class=\"figcaption\">Latest Mug Shot</figcaption>
							</figure>`;
							document.getElementById("warrant"+(i+1)).innerHTML += `
							<p>
								${item.warrants[i].name} has an active warrant for the following charges:
							</p>`
							document.getElementById("warrant"+(i+1)).innerHTML += `
								Charges:</br>`
							let charges = item.warrants[i].charges
							let pos = 0;
							for (var key in charges) {
								document.getElementById("warrant"+(i+1)).innerHTML += `${key} x${charges[key]}`
								if (pos != Object.keys(charges).length) {
									document.getElementById("warrant"+(i+1)).innerHTML += `</br>`
								}
							}
							document.getElementById("warrant"+(i+1)).innerHTML += `
							</br><p>
								If located contact law enforcement!!
							</p>`
						} else {
							document.getElementById("warrant"+(i+1)).innerHTML = 	`
							<div class="head">
								<span class="headline hl1" style="font-size: 24;">None</span>
							</div>`;
							document.getElementById("warrant"+(i+1)).innerHTML += `
							<p>
								No Warrant
							</p>`
						}
					}
					setTimeout(function() {
						for (let i = 0; i < item.columns.length; i++) {
							let adsHeight = 0;
							$(`.advert-${i}`).each(function() {
								adsHeight += $(this).height()
							});
							if (adsHeight > 0) {
								document.getElementById("column"+(i+1)).innerHTML += `
								<div display: block; style="height: ${adsHeight}px;">
								</div>`;
							}
						}
						$("#container").show();
					}, 50)
					
				} else{
                    $("#container").hide();
                }
			} else if (item !== undefined && item.type === "updateLive") {
				if (item.liveInfo.isLive) {
					if ($("#liveNews").css("display") == "block") {
						$("#liveStream").html(`<iframe id="liveIFrame" style="pointer-events: all;" src="https://www.youtube.com/embed/${item.liveInfo.liveID}?si=&autoplay=1&vq=small" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen>
						</iframe>`);
					} else {
						$("#liveNews").css("display", "block")
						$("#liveNews").html(`
								<div class="head">
									<div class="headerobjectswrapper">
										<header class="newspaper-header">LIVE COVERAGE</header>
									</div>
									<div class="subhead date">Los Santos, SA - Date</div>
								</div>
								<div class="live">
									<div id="liveStream">
										<iframe id="liveIFrame" style="pointer-events: all;" src="https://www.youtube.com/embed/${item.liveInfo.liveID}?si=&autoplay=1&vq=small" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen>
										</iframe>
									</div>
								</div>
								<hr style="width: 100%; height: 2px; color: black; border-width: 0; background-color: black; padding: 0; margin: 0;">
							`)
						const weekday = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"];
						const month = ["January","February","March","April","May","June","July","August","September","October","November","December"];
						let date = new Date();
						let formatted = weekday[date.getDay()] + " " + month[date.getMonth()] + " " + date.getDate() + ", " + date.getFullYear();
						//document.getElementById("Date").innerHTML = `Los Santos, SA - ${formatted}`;
						let divs = document.getElementsByClassName("date");
						[].slice.call( divs ).forEach(function ( div ) {
							div.innerHTML = `Los Santos, SA - ${formatted}`;
						});
					}
				} else {
					if ($("#liveNews").css("display") == "block") {
						$( "iframe" ).remove( "#liveIFrame" );
						$("#liveNews").css("display", "none")
					}
				}
			} else if (item !== undefined && item.type === "article") {
				columns = item.columns;
				var option = $('.articleSelect option:selected').val();
				$(".title-textarea").val(item.columns[Number(option)].title);
				$(".subtitle-textarea").val(item.columns[Number(option)].subtitle);
				$(".description-textarea").val(item.columns[Number(option)].body);
				$(".articleManager").fadeIn(100)
				$("#container").css("display", "none")
			}
		});
	$("#container").hide();
	};
});

function format_two_digits(n) {
    return n < 10 ? '0' + n : n;
}

popUp = function(source){
    if(!up){
        $('#popup').fadeIn('slow');
        $('.popupclass').fadeIn('slow');
        $('<img class="popupclass2" src='+source+'>').appendTo('.popupclass')
        up = true
    }
}

$(document).on('click', 'img', function(e){
    e.preventDefault();
    let source = $(this).attr('src')
    popUp(source)
});

document.onkeydown = function (data) {
    if (data.which == 27 || data.which == 112) { // ESC or F1
		if (up){
            $('#popup').fadeOut('slow');
            $('.popupclass').fadeOut('slow');
            $('.popupclass').html("");
            up = false
		} else {
			var elements = Array.from(document.querySelectorAll("iframe"));

			// Loop.
			elements.forEach(function(value) {
				value.remove();
			});
			elements = Array.from(document.querySelectorAll("img"));

			// Loop.
			elements.forEach(function(value) {
				value.remove();
			});
			$.post('https://rush-newspaper/close', JSON.stringify({}));
		}
	}
};

$(document).on('change', '.articleSelect', function() {
    var title = $(".title-textarea").val();
    var subtitle = $(".subtitle-textarea").val();
    var body = $(".description-textarea").val();
	columns[previousValue].title = title;
	columns[previousValue].subtitle = subtitle;
	columns[previousValue].body = body;
	previousValue = Number(this.value)
	$(".title-textarea").val(columns[Number(this.value)].title);
	$(".subtitle-textarea").val(columns[Number(this.value)].subtitle);
	$(".description-textarea").val(columns[Number(this.value)].body);
});

var locked = false;

function enable(option) {
	$('.submit-button').removeAttr('disabled');
	$.post('https://brazzers-report/notify', JSON.stringify({
		notify: 'Article #' + (Number(option) + 1) + " updated",
		type: 'success',
	}));
}

$(document).on('click', '.submit-button', function(e){
	e.preventDefault();
	var option = $('.articleSelect option:selected').val();
	var title = $(".title-textarea").val();
	var subtitle = $(".subtitle-textarea").val();
	var body = $(".description-textarea").val();
	columns[Number(option)].title = title
	columns[Number(option)].subtitle = subtitle
	columns[Number(option)].body = body
	$.post('https://rush-newspaper/updateArticles', JSON.stringify({
		article: {
			article: (Number(option) + 1),
			title: title,
			subtitle: subtitle,
			body: body
		}
	}));
	$(this).attr("disabled", "disabled")
	setTimeout(function() {enable(option)}, 500);
});
