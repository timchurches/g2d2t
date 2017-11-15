<?xml version="1.0" encoding="UTF-8"?>
 <xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
 <xsl:template match="/">
   <html>
   <body>
   
   <h3>ANZCTR Trial</h3>
   <table border="1">
     <tr bgcolor="#03C6FF">
	   <th>RequestNumber</th>
	   <th>Stage</th>
     <th>Submit date</th>
     <th>Approval date</th>
	   <th>ACTRN</th>
	   <th>UTRN</th>
	   <th>Study title</th>
	   <th>Scientific title</th>
	   <th>Trial acronym</th>
	   <th>Interventions</th>
	   <th>Comparator</th>
	   <th>Control</th>   
	   <th>Inclusive criteria</th>
	   <th>Inclusive min age</th>
	   <th>Inclusive min age type</th>
	   <th>Inclusive max age</th>
	   <th>Inclusive max age type</th>
	   <th>Inclusive gender</th>
	   <th>Healthy volunteer</th>
	   <th>Exclusive criteria</th>   
	   <th>Study type</th>
	   <th>Purpose</th>
	   <th>Allocation</th>
	   <th>Concealment</th>
	   <th>Sequence</th>
	   <th>Masking</th>
	   <th>Assignment</th>
	   <th>Design features</th>
	   <th>Endpoint</th>
	   <th>Statistical methods</th>
	   <th>Masking1</th>
	   <th>Masking2</th>
	   <th>Masking3</th>
	   <th>Masking4</th>
	   <th>Patient registry</th>
	   <th>Followup</th>
	   <th>Followup type</th>
	   <th>Purpose obs</th>
	   <th>Duration</th>
	   <th>Selection</th>
	   <th>Timing</th>   
	   <th>Phase</th>
	   <th>Anticipated start date</th>
	   <th>Actual start date</th>
	   <th>Anticipated end date</th>
	   <th>Actual end date</th>
	   <th>Sample size</th>
	   <th>Recruitment status</th>
	   <th>Recruitment country</th>
	   <th>Recruitment state</th>	   
	   <th>Primary sponsor type</th>
	   <th>Primary sponsor name</th>
	   <th>Primary sponsor address</th>
	   <th>Primary sponsor country</th>   
	   <th>Summary</th>
	   <th>Trial website</th>
	   <th>Publication</th>	   
	   <th>Ethics Review</th>
	   <th>Public notes</th>   
     </tr>
     <xsl:for-each select="ANZCTR_Trial">
     <tr valign="top">
	   <td><xsl:value-of select="@requestNumber"/></td>
	   <td><xsl:value-of select="stage"/></td>
	   <td><xsl:value-of select="submitdate"/></td>
	   <td><xsl:value-of select="approvaldate"/></td>
	   <td><xsl:value-of select="actrnumber"/></td>
	   <td><xsl:value-of select="trial_identification/utrn"/></td>
	   <td><xsl:value-of select="trial_identification/studytitle"/></td>
	   <td><xsl:value-of select="trial_identification/scientifictitle"/></td>
	   <td><xsl:value-of select="trial_identification/trialacronym"/></td>
	   <td><xsl:value-of select="interventions/interventions"/></td>
	   <td><xsl:value-of select="interventions/comparator"/></td>
	   <td><xsl:value-of select="interventions/control"/></td>	   
	   <td><xsl:value-of select="eligibility/inclusivecriteria"/></td>
	   <td><xsl:value-of select="eligibility/inclusiveminage"/></td>
	   <td><xsl:value-of select="eligibility/inclusiveminagetype"/></td>
	   <td><xsl:value-of select="eligibility/inclusivemaxage"/></td>
	   <td><xsl:value-of select="eligibility/inclusivemaxagetype"/></td>
	   <td><xsl:value-of select="eligibility/inclusivegender"/></td>
	   <td><xsl:value-of select="eligibility/healthyvolunteer"/></td>
	   <td><xsl:value-of select="eligibility/exclusivecriteria"/></td>   
	   <td><xsl:value-of select="trial_design/studytype"/></td>
	   <td><xsl:value-of select="trial_design/purpose"/></td>
	   <td><xsl:value-of select="trial_design/allocation"/></td>
	   <td><xsl:value-of select="trial_design/concealment"/></td>
	   <td><xsl:value-of select="trial_design/sequence"/></td>
	   <td><xsl:value-of select="trial_design/masking"/></td>
	   <td><xsl:value-of select="trial_design/assignment"/></td>
	   <td><xsl:value-of select="trial_design/designfeatures"/></td>
	   <td><xsl:value-of select="trial_design/endpoint"/></td>
	   <td><xsl:value-of select="trial_design/statisticalmethods"/></td>
	   <td><xsl:value-of select="trial_design/masking1"/></td>
	   <td><xsl:value-of select="trial_design/masking2"/></td>
	   <td><xsl:value-of select="trial_design/masking3"/></td>
	   <td><xsl:value-of select="trial_design/masking4"/></td>
	   <td><xsl:value-of select="trial_design/patientregistry"/></td>
	   <td><xsl:value-of select="trial_design/followup"/></td>
	   <td><xsl:value-of select="trial_design/followuptype"/></td>
	   <td><xsl:value-of select="trial_design/purposeobs"/></td>
	   <td><xsl:value-of select="trial_design/duration"/></td>
	   <td><xsl:value-of select="trial_design/selection"/></td>
	   <td><xsl:value-of select="trial_design/timing"/></td>   
	   <td><xsl:value-of select="recruitment/phase"/></td>
	   <td><xsl:value-of select="recruitment/anticipatedstartdate"/></td>
	   <td><xsl:value-of select="recruitment/actualstartdate"/></td>
	   <td><xsl:value-of select="recruitment/anticipatedenddate"/></td>
	   <td><xsl:value-of select="recruitment/actualenddate"/></td>
	   <td><xsl:value-of select="recruitment/samplesize"/></td>
	   <td><xsl:value-of select="recruitment/recruitmentstatus"/></td>
	   <td><xsl:value-of select="recruitment/recruitmentcountry"/></td>
	   <td><xsl:value-of select="recruitment/recruitmentstate"/></td> 
	   <td><xsl:value-of select="sponsorship/primarysponsortype"/></td>
	   <td><xsl:value-of select="sponsorship/primarysponsorname"/></td>
	   <td><xsl:value-of select="sponsorship/primarysponsoraddress"/></td>
	   <td><xsl:value-of select="sponsorship/primarysponsorcountry"/></td>   
	   <td><xsl:value-of select="ethicsAndSummary/summary"/></td> 
	   <td><xsl:value-of select="ethicsAndSummary/trialwebsite"/></td>
	   <td><xsl:value-of select="ethicsAndSummary/publication"/></td>
	   <td><xsl:value-of select="ethicsAndSummary/ethicsreview"/></td>
	   <td><xsl:value-of select="ethicsAndSummary/publicnotes"/></td>
     </tr>
     </xsl:for-each>
   </table>

   <h3>Secondary Id's</h3>
   <table border="1">
     <tr bgcolor="#03C6FF">
       <th>Secondary Id</th>
     </tr> 
	 <xsl:for-each select="ANZCTR_Trial">     
		 <xsl:for-each select="trial_identification/secondaryid">	 
		 <tr valign="top">
		   <td><xsl:value-of select="."/></td>
		 </tr>
		 </xsl:for-each>
	 </xsl:for-each>
   </table>
   
   <h3>Health conditions</h3>
   <table border="1">
     <tr bgcolor="#03C6FF">
       <th>Health condition</th>
     </tr> 
	 <xsl:for-each select="ANZCTR_Trial"> 
		 <xsl:for-each select="conditions/healthcondition">	 
		 <tr valign="top">
		   <td><xsl:value-of select="."/></td>
		 </tr>
		 </xsl:for-each>
	 </xsl:for-each>
   </table>
   
   <h3>Condition codes</h3>
   <table border="1">
     <tr bgcolor="#03C6FF">
       <th>Condition code1</th>
       <th>Condition code2</th>
     </tr> 
	 <xsl:for-each select="ANZCTR_Trial">    
		 <xsl:for-each select="conditions/conditioncode">	 
		 <tr valign="top">
		   <td><xsl:value-of select="conditioncode1"/></td>
		   <td><xsl:value-of select="conditioncode2"/></td>
		 </tr>
		 </xsl:for-each>
	 </xsl:for-each>
   </table>
   
   <h3>Intervention codes</h3>
   <table border="1">
     <tr bgcolor="#03C6FF">
       <th>Intervention code</th>
     </tr> 
	 <xsl:for-each select="ANZCTR_Trial">     
		 <xsl:for-each select="interventions/interventioncode">	 
		 <tr valign="top">
		   <td><xsl:value-of select="."/></td>
		 </tr>
		 </xsl:for-each>
	 </xsl:for-each>
   </table>
   
   <h3>Primary outcomes</h3>
   <table border="1">
     <tr bgcolor="#03C6FF">
	   <th>Outcome</th>
	   <th>Timepoint</th>
     </tr> 
	 <xsl:for-each select="ANZCTR_Trial">  
		 <xsl:for-each select="outcomes/primaryOutcome">	 
		 <tr valign="top">
		   <td><xsl:value-of select="outcome"/></td>
		   <td><xsl:value-of select="timepoint"/></td>
		 </tr>
		 </xsl:for-each>
	 </xsl:for-each>
   </table>
   
   <h3>Secondary outcomes</h3>
   <table border="1">
     <tr bgcolor="#03C6FF">
	   <th>Outcome</th>
	   <th>Timepoint</th>
     </tr> 
	 <xsl:for-each select="ANZCTR_Trial"> 
		 <xsl:for-each select="outcomes/secondaryOutcome">	 
		 <tr valign="top">
		   <td><xsl:value-of select="outcome"/></td>
		   <td><xsl:value-of select="timepoint"/></td>
		 </tr>
		 </xsl:for-each>
	 </xsl:for-each>
   </table>
   
   <h3>Recruitment - Hospitals</h3>
   <table border="1">
     <tr bgcolor="#03C6FF">
	   <th>Hospital</th>
     </tr> 
	 <xsl:for-each select="ANZCTR_Trial">  
		 <xsl:for-each select="recruitment/hospital">	 
		 <tr valign="top">
		   <td><xsl:value-of select="."/></td>
		 </tr>
		 </xsl:for-each>
	 </xsl:for-each>
   </table>
   
    <h3>Recruitment - Postcodes</h3>
   <table border="1">
     <tr bgcolor="#03C6FF">
	   <th>Postcode</th>
     </tr> 
	 <xsl:for-each select="ANZCTR_Trial">   
		 <xsl:for-each select="recruitment/postcode">	 
		 <tr valign="top">
		   <td><xsl:value-of select="."/></td>
		 </tr>
		 </xsl:for-each>
	 </xsl:for-each>
   </table>
   
   <h3>Recruitment - Country outside Australia</h3>
   <table border="1">
     <tr bgcolor="#03C6FF">
	   <th>Country</th>
	   <th>State</th>
     </tr> 
	 <xsl:for-each select="ANZCTR_Trial">   
		 <xsl:for-each select="recruitment/countryoutsideaustralia">	 
		 <tr valign="top">
		   <td><xsl:value-of select="country"/></td>
		   <td><xsl:value-of select="state"/></td>
		 </tr>
		 </xsl:for-each>
	 </xsl:for-each>
   </table>
   
   <h3>Funding sources</h3>
   <table border="1">
     <tr bgcolor="#03C6FF">
	   <th>Funding type</th>
	   <th>Funding name</th>
	   <th>Funding address</th>
	   <th>Funding country</th>
     </tr> 
	 <xsl:for-each select="ANZCTR_Trial">    
		 <xsl:for-each select="sponsorship/fundingsource">	 
		 <tr valign="top">
		   <td><xsl:value-of select="fundingtype"/></td>
		   <td><xsl:value-of select="fundingname"/></td>
		   <td><xsl:value-of select="fundingaddress"/></td>
		   <td><xsl:value-of select="fundingcountry"/></td>
		 </tr>
		 </xsl:for-each>
	 </xsl:for-each>
   </table>
   
   <h3>Secondary sponsors</h3>
   <table border="1">
     <tr bgcolor="#03C6FF">
	   <th>Sponsor type</th>
	   <th>Sponsor name</th>
	   <th>Sponsor address</th>
	   <th>Sponsor country</th>
     </tr> 
	 <xsl:for-each select="ANZCTR_Trial">    
		 <xsl:for-each select="sponsorship/secondarysponsor">	 
		 <tr valign="top">
		   <td><xsl:value-of select="sponsortype"/></td>
		   <td><xsl:value-of select="sponsorname"/></td>
		   <td><xsl:value-of select="sponsoraddress"/></td>
		   <td><xsl:value-of select="sponsorcountry"/></td>
		 </tr>
		 </xsl:for-each>
	 </xsl:for-each>
   </table>
   
   <h3>Other collaborators</h3>
   <table border="1">
     <tr bgcolor="#03C6FF">
	   <th>Other collaborator type</th>
	   <th>Other collaborator name</th>
	   <th>Other collaborator address</th>
	   <th>Other collaborator country</th>
     </tr> 
	 <xsl:for-each select="ANZCTR_Trial">    
		 <xsl:for-each select="sponsorship/othercollaborator">	 
		 <tr valign="top">
		   <td><xsl:value-of select="othercollaboratortype"/></td>
		   <td><xsl:value-of select="othercollaboratorname"/></td>
		   <td><xsl:value-of select="othercollaboratoraddress"/></td>
		   <td><xsl:value-of select="othercollaboratorcountry"/></td>
		 </tr>
		 </xsl:for-each>
	 </xsl:for-each>
   </table>
   
   <h3>Ethics committees</h3>
   <table border="1">
     <tr bgcolor="#03C6FF">
	   <th>Ethic name</th>
	   <th>Ethic address</th>
	   <th>Ethic approval date</th>
	   <th>HREC</th>
	   <th>Ethic submit date</th>
	   <th>Ethic country</th>
     </tr> 
	 <xsl:for-each select="ANZCTR_Trial">    
		 <xsl:for-each select="ethicsAndSummary/ethicscommitee">	 
		 <tr valign="top">
		   <td><xsl:value-of select="ethicname"/></td>
		   <td><xsl:value-of select="ethicaddress"/></td>
		   <td><xsl:value-of select="ethicapprovaldate"/></td>
		   <td><xsl:value-of select="hrec"/></td>
		   <td><xsl:value-of select="ethicsubmitdate"/></td>
		   <td><xsl:value-of select="ethiccountry"/></td>
		 </tr>
		 </xsl:for-each>
	 </xsl:for-each>
   </table>
   
   <h3>Attachments</h3>
   <table border="1">
     <tr bgcolor="#03C6FF">
	   <th>Attachment</th>
     </tr> 
	 <xsl:for-each select="ANZCTR_Trial">    
		 <xsl:for-each select="attachment">	 
		 <tr valign="top">
		   <td><xsl:value-of select="filepath"/></td>
		 </tr>
		 </xsl:for-each>
	 </xsl:for-each>
   </table>
   
   <h3>Contacts</h3>
   <table border="1">
     <tr bgcolor="#03C6FF">
	   <th>Type</th>
	   <th>Title</th>
	   <th>Name</th>
	   <th>Address</th>
	   <th>Phone</th>
	   <th>Fax</th>
	   <th>Email</th>
	   <th>Country</th>   
     </tr> 
	 <xsl:for-each select="ANZCTR_Trial">    
		 <xsl:for-each select="contacts/contact">	 
		 <tr valign="top">
		   <td><xsl:value-of select="type"/></td>
		   <td><xsl:value-of select="title"/></td>
		   <td><xsl:value-of select="name"/></td>
		   <td><xsl:value-of select="address"/></td>
		   <td><xsl:value-of select="phone"/></td>
		   <td><xsl:value-of select="fax"/></td>
		   <td><xsl:value-of select="email"/></td>
		   <td><xsl:value-of select="country"/></td>
		 </tr>
		 </xsl:for-each>
	 </xsl:for-each>
   </table>
   
   <br />
   <br />
   </body>
   </html>
 </xsl:template>
 </xsl:stylesheet> 