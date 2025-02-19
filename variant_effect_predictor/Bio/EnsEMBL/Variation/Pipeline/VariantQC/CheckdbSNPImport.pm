
=head1 LICENSE

 Copyright (c) 1999-2013 The European Bioinformatics Institute and
 Genome Research Limited.  All rights reserved.

 This software is distributed under a modified Apache license.
 For license details, please see

   http://www.ensembl.org/info/about/legal/code_licence.html

=head1 CONTACT

 Please email comments or questions to the public Ensembl
 developers list at <dev@ensembl.org>.

 Questions may also be sent to the Ensembl help desk at
 <helpdesk@ensembl.org>.

=head1 DESCRIPTION

This module is used in the ehive variant quality control process. 
It runs checks on a new dbSNP import to identify obvious missing data
before the full QC process starts.
If problems are discovered, the job dies killing the hive process

=cut

package Bio::EnsEMBL::Variation::Pipeline::VariantQC::CheckdbSNPImport;

use strict;
use warnings;

use base qw(Bio::EnsEMBL::Variation::Pipeline::BaseVariationProcess);

my $DEBUG = 0;



sub run {
   
    my $self = shift;

    my $dir = $self->required_param('pipeline_dir');

    ## don't check final tmp_individual_genotype_single_bp for human as merge table
    my @genotype_tables_to_check = ("population_genotype", "individual_genotype_multiple_bp");
    if($self->required_param('species') =~/homo|human/){
	push @genotype_tables_to_check, "tmp_individual_genotype_single_bp_SubInd_ch22";
    }
    else{
	push @genotype_tables_to_check, "tmp_individual_genotype_single_bp";
    }


    open my $report, ">", "$dir/preQC_report.txt" || die "Failed to open preQC_report.txt : $!\n";
    print $report "\n\tChecking pre-QC tables \n\n";


    my $varfeat_count   = $self->count_variation_feature();
    my $variation_count = $self->count_variation();
    my $allele_count    = $self->count_allele();
    my $fail_count      = $self->count_failed_variation();

    my $mean_vf   = substr(( $varfeat_count / $variation_count),0,5);
    my $mean_al   = substr(( $allele_count / $variation_count),0,5);
    my $fail_rate = substr((100 * $fail_count / $variation_count),0,5);

    my $var_no_ss_allele     = $self->count_no_ss_allele();
    my $var_no_allele_string = $self->count_no_allele_string();

    my $geno_no_sample       = $self->count_sampleless_geno(\@genotype_tables_to_check);
    my $geno_no_subsnp       = $self->count_geno_ss_problem(\@genotype_tables_to_check);
    my $geno_no_allele       = $self->count_alleleless_geno(\@genotype_tables_to_check);

    my $varfeat_no_pos       = $self->count_bad_varfeat();
    my $varfeat_no_seqreg    = $self->count_seq_region_problem();

    my $complimented_desc    = $self->check_complimented_desc();
    

    print $report "Post-import preQC check

Total Variation:        $variation_count
Total VariationFeature: $varfeat_count ( $mean_vf per variation )
Total Allele:           $allele_count ( $mean_al per variation )

Failed Variation:       $fail_count (failure rate: $fail_rate )

Variations without ss alleles:      $var_no_ss_allele  
Variations without allele_string:   $var_no_allele_string 

Genotypes without samples:          $geno_no_sample
Genotypes without real ss:          $geno_no_subsnp
Genotypes without alleles:          $geno_no_allele

VariationFeature without start/end: $varfeat_no_pos 
VariationFeature without seqregion: $varfeat_no_seqreg

\n";  

    print $report "ERROR: $complimented_desc complimented descriptions found - to be fixed manually\n\n" if $complimented_desc >0;

    if($var_no_ss_allele    > 0  || 
       $var_no_allele_string > 0 || 
       $variation_count  == 0    ||
       $varfeat_count    == 0    ||
       $allele_count     == 0    ||
       $geno_no_sample     >0    ||
       $varfeat_no_pos     >0    ||
       $varfeat_no_seqreg  >0    ||
       $geno_no_subsnp     >0
       ){

        print $report "Exiting - missing data to import\n"; 
        die;  ## rest of QC process does not start if this fails
    }


}


sub count_variation_feature{

    my $self = shift;
    my $var_dba   = $self->get_species_adaptor('variation');

    my $varfeat_ext_sth  = $var_dba->dbc->prepare(qq[ select count(*) from variation_feature]);
    $varfeat_ext_sth->execute() || die "Failed to extract varfeat count \n";
    my $varfeat_count = $varfeat_ext_sth->fetchall_arrayref();

    defined $varfeat_count->[0]->[0]  ?  return $varfeat_count->[0]->[0] : return 0;
}


sub count_variation{

    my $self = shift;
    my $var_dba   = $self->get_species_adaptor('variation');

    my $var_ext_sth   = $var_dba->dbc->prepare(qq[ select count(*) from variation]);
    $var_ext_sth->execute() || die "Failed to extract var count\n";
    my $var_count     = $var_ext_sth->fetchall_arrayref();

    defined $var_count->[0]->[0]  ?  return $var_count->[0]->[0] : return 0;
}

sub count_allele{

    my $self = shift;
    my $var_dba   = $self->get_species_adaptor('variation');

    my $allele_ext_sth = $var_dba->dbc->prepare(qq[ select count(*) from allele]);
    $allele_ext_sth->execute()|| die "Failed to extract allele count\n";   
    my $allele_count   = $allele_ext_sth->fetchall_arrayref();

    defined $allele_count->[0]->[0]  ?  return $allele_count->[0]->[0] : return 0;
}


sub count_failed_variation{

    my $self = shift;
    my $var_dba   = $self->get_species_adaptor('variation');


    my $fail_ext_sth  = $var_dba->dbc->prepare(qq[ select count(*) from failed_variation]);
    $fail_ext_sth->execute() || die "Failed to extract fail count\n";   
    my $fail_count    = $fail_ext_sth->fetchall_arrayref();

    defined $fail_count->[0]->[0]  ?  return $fail_count->[0]->[0] : return 0;
}

## Checks for missing data
 
 sub count_no_ss_allele{

    my $self = shift;
    my $var_dba   = $self->get_species_adaptor('variation');

  
    my $no_allele_ext_sth      = $var_dba->dbc->prepare(qq[ select count(*) from variation 
                                                            where variation_id not in (select variation_id  from allele)]);

    $no_allele_ext_sth->execute() || die "Failed to extract no_allele count\n";   
    my $no_allele_count    = $no_allele_ext_sth->fetchall_arrayref();

    defined $no_allele_count->[0]->[0]  ?  return $no_allele_count->[0]->[0] : return 0;
}

=head2 count_no_allele_string

  Look for variants without allele data

=cut
sub count_no_allele_string{

    my $self = shift;
    my $var_dba   = $self->get_species_adaptor('variation');

    my $no_allele_str_ext_sth  = $var_dba->dbc->prepare(qq[ select count(*) from variation
                                                            where variation_id not in (select variation_id  from allele_string)]);
 
    $no_allele_str_ext_sth->execute() || die "Failed to extract no allele string count\n";
    my $no_allele_str_count    = $no_allele_str_ext_sth->fetchall_arrayref();

    defined $no_allele_str_count->[0]->[0]  ?  return $no_allele_str_count->[0]->[0] : return 0;

 
}


=head2 count_bad_varfeat

  Look for variants without coordinates

=cut
sub count_bad_varfeat{

    my $self = shift;
    my $var_dba   = $self->get_species_adaptor('variation');

    my $varfeat_ext_sth = $var_dba->dbc->prepare(qq[ select count(*) from variation_feature where seq_region_start =0 or seq_region_end =0  ]);
    $varfeat_ext_sth->execute()|| die "Failed to extract failed seq_region_start/end count\n";   
    my $varfeat_count   = $varfeat_ext_sth->fetchall_arrayref();

    defined $varfeat_count->[0]->[0]  ?  return $varfeat_count->[0]->[0] : return 0;
}
=head2 count_seq_region_problem

  Look for variants without sequence locations data

=cut
sub count_seq_region_problem{

    my $self = shift;
    my $var_dba   = $self->get_species_adaptor('variation');

    my $varfeat_ext_sth = $var_dba->dbc->prepare(qq[ select count(*) from variation_feature 
                                                     left outer join  seq_region on ( variation_feature.seq_region_id =  seq_region.seq_region_id)
                                                     where  seq_region.name is null  ]);

    $varfeat_ext_sth->execute()|| die "Failed to extract failed seq_region_id count\n";   
    my $varfeat_count   = $varfeat_ext_sth->fetchall_arrayref();

    defined $varfeat_count->[0]->[0]  ?  return $varfeat_count->[0]->[0] : return 0;
}


### Checks on genotype tables

=head2 count_sampleless_geno

  Look for genotypes without sample data

=cut
sub count_sampleless_geno{

    my $self   = shift;
    my $tables = shift;

    my $var_dba   = $self->get_species_adaptor('variation');

    my $tot = 0;
    #my @individual_tables = ('individual_genotype_multiple_bp', 'tmp_individual_genotype_single_bp_SubInd_ch22', 'tmp_individual_genotype_single_bp');
    #my @population_tables = ('population_genotype');

   foreach my $table ( @{$tables} ){ 

       # indiviudal population???
       my $sample = '';
       my $sample_id = '';
       if ($table =~ /individual/) {
           $sample = 'individual';
           $sample_id = 'individual_id';
       } else {
          $sample = 'population';
          $sample_id = 'population_id';
       }
       my $no_sample_ext_sth  = $var_dba->dbc->prepare(qq[select count(*) from $table where $sample_id not in (select $sample_id from $sample) ]);
       $self->warning("At sampleless_geno with table  $table");
       $no_sample_ext_sth->execute() || die "Failed to extract no sample count for $table\n";
       my $no_sample_count    = $no_sample_ext_sth->fetchall_arrayref();

       if (defined $no_sample_count->[0]->[0]){
	   $tot += $no_sample_count->[0]->[0];
       }
   }

   return $tot;

}

=head2 count_alleleless_geno

  Look for genotypes without allele data

=cut
sub count_alleleless_geno{

    my $self   = shift;
    my $tables = shift;

    my $var_dba   = $self->get_species_adaptor('variation');

    my $total_problem_genotypes = 0;

   foreach my $table ( @{$tables} ){ 

     my $no_allele_ext_sth  = $var_dba->dbc->prepare(qq[select count(*) from $table where allele_1 is null or allele_2 is null ]);

     $no_allele_ext_sth->execute() || die "Failed to extract no allele count for $table\n";
     my $no_allele_count    = $no_allele_ext_sth->fetchall_arrayref();

     if (defined $no_allele_count->[0]->[0]){
        $total_problem_genotypes += $no_allele_count->[0]->[0];
      }
  }

  return $total_problem_genotypes;

}

=head2 count_sampleless_geno

  Look for genotypes without subsnp ids

=cut
sub count_geno_ss_problem{

    my $self   = shift;
    my $tables = shift;

    my $var_dba   = $self->get_species_adaptor('variation');

   ## useful (slow) SQL:
   ## select count(*) from tmp_individual_genotype_single_bp  where subsnp_id  not in (select subsnp_id from allele)

    my $total_problem = 0;

    my $max_subsnp_ext_sth      = $var_dba->dbc->prepare(qq[ select max(subsnp_id) from allele]);
    $max_subsnp_ext_sth->execute()||die "Failed to find max subsnp_id\n";
    my $max_subsnp = $max_subsnp_ext_sth->fetchall_arrayref();
    unless(defined  $max_subsnp->[0]->[0]){ die "Failed to find max subsnp_id\n";}

   foreach my $table ( @{$tables} ){ 
    
    my $geno_ext_sth = $var_dba->dbc->prepare(qq[ select count(*) from $table where subsnp_id >  $max_subsnp->[0]->[0] ]);

      $geno_ext_sth->execute()|| die "Failed to extract failed genotype subsnp count for $table\n";   
      my $geno_count  = $geno_ext_sth->fetchall_arrayref();
      $total_problem += $geno_count->[0]->[0];
    }

    return $total_problem;
}


=head2 check_complimented_desc

  Look for described alleles complimented in error
     eg "(318 BP DELETION)" =>  ")NOIAELEH PV 813("
  These can be complex, so are flagged for manual fixing

=cut
sub check_complimented_desc{

    my $self = shift;

    my $var_dba   = $self->get_species_adaptor('variation');

    my $data_ext_sth = $var_dba->dbc->prepare(qq[ select count(*) from allele_string 
                                                  where allele_string like '%NOIAELEH%'
                                                  or allele_string like '%NOIAYESNI%']);

    $data_ext_sth->execute()||die "Failed to check for complimented allele strings\n";

    my $count = $data_ext_sth->fetchall_arrayref();

    defined $count->[0]->[0]  ?  return $count->[0]->[0] : return 0;
}

1;
