function getOrganisms() {
	
	$.post(infoURL,
		   { organism_id: $('#organismID').val() },  
		 	function(data) {
				$("#list > tbody").remove();
				if (data['observations'] != null) {  
					$("#list").append("<tbody></tbody>");
					$.each (data['observations'], function(key, value) {
						var user ='';
						switch(value['provider'])
						{
							case '':
							  break;
							default:
						      if (value['user'] != '') {
						    	  user = '<a href="'+ value['user_url'] +'"><img src="/static/images/' + value['provider'] + '.jpg" width="15" height="15"> ' + value['user'] + '</a>';
						      }
						}
						$("#list > tbody").append("<tr> " + 
															"<td>" + value['type'] + "</td>" +
															"<td>" + String(value['date']).replace('null', '') + "</td>" +
															"<td>" + String(value['latitude']).replace('null', '') + "</td>" +
															"<td>" + String(value['longitude']).replace('null', '') + "</td>" +
															"<td>" + String(value['location_detail']).replace('null', '') + "</td>" +
															"<td>" + user + "</td>" +
															"<td><a href=\"" + value['url'] + "\">Edit</a></td>" +
															"</tr>");
					});
					
					$("#list").trigger("update"); 	
					setTimeout(function() {		
							var sorting = [[0,0],[1,0]]; 
      						 $("#list").trigger("sorton",[sorting]);},
						1250);
				}
			}
      )
		
}