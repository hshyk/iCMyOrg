function getOrganisms() {
	
	 
	$.post(infoURL,
		   { organism_id: $('#organismID').val() },  
		 	function(data) {
				$("#list > tbody").remove();
				if (data['states'] != null) {  
					$("#list").append("<tbody></tbody>");
					$.each (data['states'], function(key, value) {
						$("#list > tbody").append("<tr> " + 
															"<td>" + value['character'] + "</td>" +
															"<td>" + value['name'] + "</td>" +
															"<td>" + String(value['low_value']).replace('null', '') + "</td>" +
															"<td>" + String(value['high_value']).replace('null', '') + "</td>" +
															"<td><a href=\"" + value["url"]+ "\">Edit</a></td>" +
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