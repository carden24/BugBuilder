#!/usr/bin/perl

######################################################################
# 
# Script to extract protein sequences from prokka-annotated embl
# entry for running interproscan
#
# $HeadURL: https://bss-srv4.bioinformatics.ic.ac.uk/svn/BugBuilder/trunk/bin/get_prokka_proteins.pl $
# $Author: jamesa $
# $Revision: 38 $
# $Date: 2013-08-28 09:36:57 +0100 (Wed, 28 Aug 2013) $
#
######################################################################

use warnings;
use strict;

use Bio::SeqIO;
{
    my $embl = shift or die "Usage: $0 emblfile: $!";
    my $io = Bio::SeqIO->new( -file => $embl, -format => 'embl' );
    my ( $id, $outIO );
    while ( my $seq = $io->next_seq() ) {
        my @features = $seq->get_all_SeqFeatures();
      FEATURE: foreach my $feat (@features) {
            if ( !$id && $feat->primary_tag eq 'source' ) {
                $id = ( $feat->get_tag_values('strain') )[0];
                $outIO = Bio::SeqIO->new( -format => 'fasta',
                                          -file   => ">$id.prot.fasta" );
                next FEATURE;
            }

            if ( $feat->primary_tag eq 'CDS' ) {
                my $seq = Bio::Seq->new(
                       -display_id => ( $feat->get_tag_values('locus_tag') )[0],
                       -seq => ( $feat->get_tag_values('translation') )[0] );
                $outIO->write_seq($seq);
            }

        }
    }

}
