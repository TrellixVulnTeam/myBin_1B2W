=pod 

=head1 NAME

Bio::EnsEMBL::Funcgen::RunnableDB::DefineOuputSet

=head1 DESCRIPTION

=cut

package Bio::EnsEMBL::Funcgen::Hive::DefineOutputSet;

use warnings;
use strict;
 
use Bio::EnsEMBL::Utils::Exception qw (throw);
use Bio::EnsEMBL::Funcgen::Utils::EFGUtils qw(scalars_to_objects);

use base ('Bio::EnsEMBL::Funcgen::Hive::BaseDB');

#This assumes the InputSet has been previously registered, 
#and now we want simply to define/fetch the data set, feature and result set based on these data.

#todo -slice_import_status?



sub fetch_input {   # fetch parameters...
  my $self = shift @_;
  $self->SUPER::fetch_input;
  
  #This is only redefining it local to this process, not to the hive tables anywhere
  #Flow this later
  #todo set in Base, based on pipeline_name or DBNAME?
  #$self->set_dir_param('output_dir', 
  #                     $self->param('root_output_dir').'/'.$self->param('pipeline_name').'/'.$self->param('set_name'),
  #                     1); #create flag
  
  #Now set in BaseDB::pipeline_wide_parameters                                    


  my ($iset)      = @{&scalars_to_objects($self->out_db, 'InputSet',
                                                'fetch_by_dbID',
                                                [$self->param('dbID')] ) };

  if(! defined $iset){
    throw('Cannot fetch '.$self->param('name').
      ' ('.$self->param('dbID').') InputSet from the database');
  } 

  $self->param('input_set', $iset);

  
  #refactor this default_analysis method in BaseDB?
  my %default_analyses;
  my @set_types = ('result_set');
  push @set_types, 'feature_set' if ! $self->param('result_set_only');
  
  
  #TODO Validate default set analysis keys exist as feature_type class or name?
  #This would fail for species with low coverage i.e. some names may be absent
  
  foreach my $set_type( @set_types ){   
    my $set_lname = $self->param($set_type.'_analysis');
  
    if(! defined $set_lname){
      
      $default_analyses{$set_type} = $self->param('default_'.$set_type.'_analyses');     
      #catch with param_silent rahter than param_required as it is 
      #not mandatory if set_type analysis is defined
      
      if(! defined $default_analyses{$set_type}){
        throw("Please define -${set_type}_analysis or add to default_${set_type}_analyses".
          " in the default_options config");
      }
      
     
      if(exists $default_analyses{$set_type}{$iset->feature_type->name}){
        $set_lname = $default_analyses{$set_type}{$iset->feature_type->name}; 
      }
      elsif(exists $default_analyses{$set_type}{$iset->feature_type->class}){
        $set_lname = $default_analyses{$set_type}{$iset->feature_type->class};
      }
      else{
        throw("No default $set_type analysis available for ".$iset->feature_type->name.
          '('.$iset->feature_type->class.
          ").\n Please add FeatureType name or class to  default_${set_type}_analyses ".
          "in default_options config or specify -${set_type}_analysis"); 
      }
    }                                  
    
    #Catch undefs in config
    if(! defined $set_lname){
      throw("Unable to identify defined $set_type analysis in config for ".$iset->feature_type->name.
      ".\nPlease define in default_${set_type}_analyses config or specify -${set_type}_analysis");     
    }    
    #can't use process_params here as the param name does match the object name
    #We could over-ride this with a second arrayref of class names                                      
    $self->param($set_type.'_analysis', 
                 &scalars_to_objects($self->out_db,
                                     'Analysis', 
                                     'fetch_by_logic_name',
                                     [$set_lname])->[0]);                                              
  }

  return;
}


#TODO handle ResultSet only run
#This would take a flag and create the ResultSet in isolation
#would need to validate not FeatureSet stuff was set
#this might clash with some defaults if we had mixed set types in the pipeline
#i.e. some with and some without datasets
#feature_set_analysis is always created dynamically anyway, so this would be dependant on
#-result_set_only 

sub run {   # Check parameters and do appropriate database/file operations... 
  my $self = shift @_;
  
  my $helper = $self->helper;  
  my $iset = $self->param('input_set');
  my $set;    

  #todo migrate this to the Importer as define_OutputSet
  #there is some overlap here of param validation between BaseImporter and hive
  
      
  #Never set -FULL_DELETE here!
  #It is unwise to do this in a pipeline and should be handled
  #on a case by case basis using a separate rollback script    
  
  #Should also never really specify recover here either?
  #This bascailly ignores the fact that a ResultSet may be lin ked to other DataSets
  
  
  if( $self->param('result_set_only') ){
    throw('Pipeline does not yet support creation of a ResultSet without and associated Feature/DataSet');
     
    $set = $helper->define_ResultSet
      ( 
       -NAME                 => $iset->name,#.'_'.$rset_anal->logic_name,
       #-FEATURE_CLASS        => result | dna_methylation',
       #currently set dynamically in define_ResultSet
       -SUPPORTING_SETS      => [$iset],
       -DBADAPTOR            => $self->out_db,
       -RESULT_SET_ANALYSIS  => $self->param('result_set_analysis'),
       -RESULT_SET_MODE      => $self->param('result_set_mode'),
       -ROLLBACK             => $self->param('rollback'),
       -RECOVER              => $self->param('recover'),
       -SLICES               => $self->param('slices'),
       -CELL_TYPE            => $iset->cell_type,
       -FEATURE_TYPE         => $iset->feature_type,
     );
        
  }
  else{
    my $fset_anal = $self->param('feature_set_analysis');
    
    $set = $helper->define_DataSet
      (
       -NAME                 => $iset->name.'_'.$fset_anal->logic_name,
       -FEATURE_CLASS        => 'annotated', #Is there overlap with rset feature_class here?
       -SUPPORTING_SETS      => [$iset],
       -DBADAPTOR            => $self->out_db,
       
       -FEATURE_SET_ANALYSIS => $fset_anal,
       -RESULT_SET_ANALYSIS  => $self->param('result_set_analysis'),
       -RESULT_SET_MODE      => $self->param('result_set_mode'),
       -ROLLBACK             => $self->param('rollback'),
       -RECOVER              => $self->param('recover'),
       -SLICES               => $self->param('slices'),    
       -CELL_TYPE            => $iset->cell_type,
       -FEATURE_TYPE         => $iset->feature_type,
       #-DESCRIPTION   => ?
       #-DISPLAY_LABEL => ?
      );  
  }


  #No tracking required here?
  #Todo review whether rollback handles status entries correctly
  

  #Add set_type here as result_set_only could be change between writing
  #this output_id and running a down stream analysis  
  $self->param('output_id', {dbID       => $set->dbID, 
                             set_name   => $set->name,
                             set_type   => ($self->param('result_set_only') ? 
                                             'ResultSet' : 'DataSet')}
              );
  
  return 1;
}


sub write_output {  # Create the relevant jobs
  my $self = $_[0];
  $self->dataflow_output_id($self->param('output_id'), 1);
  return;
}


1;
