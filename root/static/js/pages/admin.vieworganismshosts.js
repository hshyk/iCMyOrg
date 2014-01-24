function getOrganisms() {
	
	 
	$.post(infoURL,
		   { organism_id : $('#organismID').val() },  
		 	function(data) {
				$("#hosts > tbody").remove();
				if (data['hosts'] != null) {  
					$("#list").append("<tbody></tbody>");
					$.each (data['hosts'], function(key, value) {
						$("#list > tbody").append("<tr> " + 
															"<td>" + value['scientific_name'] + "</td>" +
															"<td>" + value['common_name'] + "</td>" +
															"<td><a href=\"" + value["url"]+ "\">Edit</a></td>" +
															"</tr>");
					});
					
					$("#list").trigger("update"); 	
				}
			}
      )
	
}