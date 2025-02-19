#!perl
  #use strict;
  #use warnings;
  use SOAP::Lite;
  use HTTP::Cookies;

  my $soap = SOAP::Lite                             
     -> uri('http://service.session.sample')                
     -> proxy('http://david.abcc.ncifcrf.gov/webservice/services/DAVIDWebService',
                cookie_jar => HTTP::Cookies->new(ignore_discard=>1));

 #user authentication by email address
 #For new user registration, go to http://david.abcc.ncifcrf.gov/webservice/register.htm 
 my $check = $soap->authenticate('yourEmail@your.org')->result;
  	print "\nUser authentication: $check\n";

 if (lc($check) eq "true") { 	
 #addList
 #WARNING: user should limit the number of genes in the list within 3000, or DAVID will turn down the service due to resource limitation.
 my $inputIds = '31741_at,31734_at,32696_at,37559_at,41400_at,35985_at,39304_g_at,41438_at,35067_at,32919_at,35429_at,36674_at,967_g_at,36669_at,39242_at,39573_at,39407_at,33346_r_at,40319_at,2043_s_at,1788_s_at,36651_at,41788_i_at,35595_at,36285_at,39586_at,35160_at,39424_at,36865_at,2004_at,36728_at,37218_at,40347_at,36226_r_at,33012_at,37906_at,32872_at,989_at,32718_at,36957_at,32645_at,37628_at,33825_at,35687_at,32779_s_at,34493_at,31564_at,887_at,34712_at,32897_at,34294_at,41365_at,41446_f_at,34375_at,875_g_at,41099_at,919_at,38970_s_at,39159_at,34184_at,1018_at,38032_at,35956_s_at,35536_at,34562_at,1867_at,35957_at,39519_at,41657_at,38491_at,652_g_at,35776_at,34989_at,33455_at,39950_at,37723_at,31977_at,38629_at,34581_s_at,36210_g_at,35120_at,41532_at,37889_at,1332_f_at,40540_at,41105_s_at,1919_at,37542_at,39698_at,36711_at,36809_at,1167_s_at,31648_at,32364_at,40792_s_at,38685_at,41358_at,32931_at,35294_at,39870_at,38654_at,257_at,39071_at,35606_at,41726_at,33094_s_at,32405_at,1432_s_at,33698_at,408_at,39748_at,1953_at,36100_at,36101_s_at,1372_at,35314_at,40790_at,2030_at,179_at,1852_at,259_s_at,38024_at,35376_f_at,41779_at,39232_at,41159_at,40365_at,31626_i_at,40385_at,35613_at,37506_at,38207_at,887_at,600_at,1461_at,38691_s_at,1267_at,1177_at,1125_s_at,2036_s_at,31615_i_at,37283_at,40954_at,31758_at,36960_at,33143_s_at,37048_at,38538_at,1005_at,34963_at,39408_at,32464_at,706_at,1276_g_at,164_at,41445_at,40735_at,1891_at,1258_s_at,40856_at,1911_s_at,31562_at,32359_at,274_at,1804_at,41387_r_at,848_at,41499_at,39448_r_at,34537_at,36459_at,35500_at,37139_at,612_s_at,32133_at,39757_at,37629_at,38463_s_at,568_at,749_at,1939_at,38018_g_at,1857_at,32699_s_at,40661_at,1994_at,38373_g_at,33893_r_at,1388_g_at,35345_at,1385_at,36615_at,1263_at,37385_at,1774_at,37233_at,39753_at,32626_at,35915_at,35714_at,31669_s_at,36519_at,40473_at,1750_at,33751_at,37831_at,35472_at,41825_at,34666_at,35471_g_at,31888_s_at,37722_s_at,35414_s_at,39750_at,35726_at,37662_at,33802_at,352_at,31737_at,37938_at,36161_at,31558_at,34475_at,37223_at,38953_at,37857_at,189_s_at,41169_at,33092_at,38660_at,40895_g_at,37146_at,1936_s_at,38860_at,40210_at,41180_i_at,31586_f_at,33366_at,31521_f_at,762_f_at,1124_at,36009_at,41111_at,36749_at,37310_at,31522_f_at,35768_at,39421_at,39967_at,35992_at,38356_at,39331_at,34145_at,35378_at,199_s_at,35966_at,1866_g_at,37377_i_at,37378_r_at,833_at,31586_f_at,38062_at,34981_at,1569_r_at,1548_s_at,41446_f_at,36999_at,34226_at,33385_g_at,36173_r_at,1007_s_at,35149_at,38671_at,1973_s_at,37724_at,37317_at,33829_at,36532_at,39372_at,41717_at,38221_at,37418_at,33120_at,136_at,33492_at,1602_at,41505_r_at,41736_g_at,37862_at,31859_at,40913_at,35956_s_at,32193_at,1148_s_at,1244_at,38684_at,37440_at,32186_at,1242_at,39503_s_at,224_at,38374_at,36018_at,36603_at,33288_i_at,33662_at,33555_at,33539_at,430_at,471_f_at,1369_s_at,35372_r_at,38089_at,40310_at,41106_at,41216_r_at,32815_at,37463_r_at,33470_at,40522_at,1463_at,1743_s_at,1895_at,32583_at,35440_g_at,1091_at,1649_at,287_at,32119_at,131_at,38642_at,33922_at,35886_at,38326_at,38823_s_at,41088_at,41371_at,39841_at,32486_at,41234_at,41598_at,40478_at,37606_at,37170_at,34857_at,32062_at,37762_at,36052_at,40442_f_at,41550_at,36621_at,36929_at,38645_at,34438_at,39587_at,36562_at,37155_at,36055_at,36754_at,33545_at,1520_s_at,39402_at,32265_at,32679_at,1829_at,40669_at,31694_at,41382_at,41446_f_at,38391_at,34560_at,40098_at,32522_f_at,988_at,789_at,1270_at,1139_at,33665_s_at,1237_at,412_s_at,34688_at,31353_f_at,41856_at,32928_at,37584_at,32379_f_at,936_s_at,2082_s_at,36479_at,39175_at,32007_at,36103_at,37270_at,40840_at,37206_at,37365_at,37820_at,35848_at,37111_g_at,39522_at,36760_at,35018_at,31745_at,37424_at,36507_at,719_g_at,34165_at,41850_s_at';
 my $idType = 'AFFYMETRIX_3PRIME_IVT_ID';
 my $listName = 'make_up';
 my $listType=0;
 my $list = $soap ->addList($inputIds, $idType, $listName, $listType)->result;
  	print "\n$list of list was mapped\n"; 

 
 #set user defined categories 
 #my $categories = $soap ->setCategories("abcd,BBID,BIOCARTA,COG_ONTOLOGY,INTERPRO,KEGG_PATHWAY,OMIM_DISEASE,PIR_SUPERFAMILY,SMART,SP_PIR_KEYWORDS,UP_SEQ_FEATURE")->result;
 #to user DAVID default categories, send empty string to setCategories():
 my $categories = $soap ->setCategories("")->result;
 print "\nValid categories: \n$categories\n\n";  
 
open (termClusterReport, ">", "termClusterReport.txt");

#test getTermClusterReport(int overlap,int initialSeed, int finalSeed, double linkage, int kappa)

my $overlap=3;
my $initialSeed = 3;
my $finalSeed = 3;
my $linkage = 0.5;
my $kappa = 20;
my $termClusterReport = $soap->getTermClusterReport($overlap,$initialSeed,$finalSeed,$linkage,$kappa);
#my $termClusterReport = $soap->getTermClusterReport();
	my @simpleTermClusterRecords = $termClusterReport->paramsout; 	
	print "Total TermClusterRecords: ".(@simpleTermClusterRecords+1)."\n\n"; 
	my @simpleTermClusterRecordKeys = keys %{$termClusterReport->result};		
	my @simpleTermClusterRecordValues = values %{$termClusterReport->result};
		
	@chartRecords = @{$simpleTermClusterRecordValues[1]};
	
	print termClusterReport "Annotation Cluster 1\tEnrichment Score:  $simpleTermClusterRecordValues[2]\n";
	print termClusterReport "Category\tTerm\tCount\t%\tPvalue\tGenes\tList Total\tPop Hits\tPop Total\tFold Enrichment\tBonferroni\tBenjamini\tFDR\n";
	for $j (0 .. (@chartRecords-1))
	{			
		%chartRecord = %{$chartRecords[$j]};	
			
		my $categoryName = $chartRecord{"categoryName"};
		my $termName = $chartRecord{"termName"};
		my $listHits = $chartRecord{"listHits"};
		my $percent = $chartRecord{"percent"};
		my $ease = $chartRecord{"ease"};
		my $Genes = $chartRecord{"geneIds"};
		my $listTotals = $chartRecord{"listTotals"};
		my $popHits = $chartRecord{"popHits"};
		my $popTotals = $chartRecord{"popTotals"};
		my $foldEnrichment = $chartRecord{"foldEnrichment"};
		my $bonferroni = $chartRecord{"bonferroni"};
		my $benjamini = $chartRecord{"benjamini"};
		my $FDR = $chartRecord{"afdr"};
		
		print termClusterReport "$categoryName\t$termName\t$listHits\t$percent\t$ease\t$Genes\t$listTotals\t$popHits\t$popTotals\t$foldEnrichment\t$bonferroni\t$benjamini\t$FDR\n";
	
	}	
	for $k (0 .. (@simpleTermClusterRecords-1))
	{	
		my $itr=$k+2;
		@simpleTermClusterRecordValues = values %{$simpleTermClusterRecords[$k]};
		@chartRecords = @{$simpleTermClusterRecordValues[1]};
		print termClusterReport "\nAnnotation Cluster $itr\tEnrichment Score:  $simpleTermClusterRecordValues[2]\n";
		print termClusterReport "Category\tTerm\tCount\t%\tPvalue\tGenes\tList Total\tPop Hits\tPop Total\tFold Enrichment\tBonferroni\tBenjamini\tFDR\n";
		for $j (0 .. (@chartRecords-1))
		{			
			%chartRecord = %{$chartRecords[$j]};
			
			my $categoryName = $chartRecord{"categoryName"};
			my $termName = $chartRecord{"termName"};
			my $listHits = $chartRecord{"listHits"};
			my $percent = $chartRecord{"percent"};
			my $ease = $chartRecord{"ease"};
			my $Genes = $chartRecord{"geneIds"};
			my $listTotals = $chartRecord{"listTotals"};
			my $popHits = $chartRecord{"popHits"};
			my $popTotals = $chartRecord{"popTotals"};
			my $foldEnrichment = $chartRecord{"foldEnrichment"};
			my $bonferroni = $chartRecord{"bonferroni"};
			my $benjamini = $chartRecord{"benjamini"};
			my $FDR = $chartRecord{"afdr"};	
			
			print termClusterReport "$categoryName\t$termName\t$listHits\t$percent\t$ease\t$Genes\t$listTotals\t$popHits\t$popTotals\t$foldEnrichment\t$bonferroni\t$benjamini\t$FDR\n";		
		}
	}
	close termClusterReport;
	print "termClusterReport.txt generated\n";
}

__END__

#push(@simpleTermClusterRecords,$termClusterReport->result);
