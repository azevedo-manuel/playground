# ubr - UCOS Backup Reporter

use strict;
use File::Find;
use Data::Dumper;
use Time::Local;


#
# App parameters

my $baseDir         = "./backup";
my $xmlString       = "drfComponent.xml";

my $yellowAlertDays = 7;
my $redAlertDays    = 15;

# Do not change beyond this point
#


my %backupData;
my $fileCounter     = 0;

# Used for file handling
sub handlefile {

    # Temporary Hash to store the data of each file
    my %backupFile;

    # If the found file matches this string and the end of the file, process it
    if ($_ =~ /$xmlString$/) {

        
        my $backupDate;
        my $backupDateEpoch;
        my $backupEpoch;
        my $backupPrimaryHost;

        # The hostname is between two underscores followed by the XML string. If not found, maybe it's an older DRF version
        if ($_ =~ /.*_(.*)_$xmlString$/) {
            $backupPrimaryHost = $1;
        } else {
            $backupPrimaryHost = "= Not defined =";
        }

        # The date format is YYYY-MM-DD-HH-MM-SS and should start at the beginning of the file
        if ($_ =~ /^(\d{4}-\d{2}-\d{2}-\d{2}-\d{2}-\d{2})_.*/) {
            $backupDate = $1;
        } else {
            $backupDate = "= Invalid date =";
        }

        # Build the hash with the data.
        %backupFile = ( 
            'backupFullName'    => $File::Find::name,
            'backupLocation'    => $File::Find::dir,
            'backupFile'        => $_,
            'backupPrimaryHost' => $backupPrimaryHost,
            'backupDate'        => $backupDate,
            'backupEpoch'       => getEpoch($backupDate),
        );
        
        # Add it to the backupData hash. The index is just used to order the keys.
        my $item = $backupData{$File::Find::dir}{'count'}++;
        $backupData{$File::Find::dir}{$item} = \%backupFile;
        # Increase the counter index
        $fileCounter++;
    } 
}

# Convert Cisco DRF format date to Epoch date
# Format must be: YYYY-MM-DD-HH-MM-SS
sub getEpoch{
    my $dateYear;
    my $dateMonth;
    my $dateDay;
    my $dateHour;
    my $dateMinutes;
    my $dateSeconds;

    ($dateYear,$dateMonth,$dateDay,$dateHour,$dateMinutes,$dateSeconds) = ($1 =~ /^(\d+)-(\d+)-(\d+)-(\d+)-(\d+)-(\d+)/);
    # Timelocal expects the months to be in the format 0..11 instead of 1..12
    return timelocal($dateSeconds, $dateMinutes,$dateHour,$dateDay,$dateMonth-1,$dateYear);
}




# Main execution

# Find backup files
find(\&handlefile,$baseDir);
# Usually the first directory found does not contain backups. Let's remove it from the array
print Dumper(\%backupData);

print "Current time in Epoch time (seconds since 1-Jan-1970): ",time(), "\n";


print "Total backup directories found: ",scalar keys %backupData,"\n";
print "Total XML files found:          $fileCounter \n";


foreach my $key (keys %backupData) {
    printf("%-50s :\n",$key);
    if ($backupData{$key}{'count'} > 0) {
        foreach my $item (keys %backupData{$key}) {
            if ($item ne "count") {
                #print "Key: $key, Item: $item\n";
                my $days = int((time()-$backupData{$key}{$item}{'backupEpoch'})/86400);
                print "  * $backupData{$key}{$item}{'backupFile'} is ";
                if ($days > $redAlertDays) {
                    print "a very old backup! It's ";
                } elsif ($days > $yellowAlertDays) {
                    print "a somewhat old backup. It's  ";
                }
                print $days;
                print " days old\n";
            }
        }
    }
}


