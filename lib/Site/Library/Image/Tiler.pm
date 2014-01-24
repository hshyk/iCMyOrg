package Site::Library::Image::Tiler;
use strict;
use warnings;
use Moose;
use File::Find::Rule;
use File::Type;
use File::Remove qw(remove);
use Archive::Zip;
use Archive::Zip::MemberRead;
use File::Path;
use File::Path qw(make_path remove_tree);
use Getopt::Long;
use Image::Magick;

sub new {
	my ($class, $args) = @_;

    my $self  = 
    {
    	'directory'	=>	$args->{directory},
    	'convert'		=>	$args->{convert},
    	'mogrify'		=>	$args->{mogrify},
    	'separator'	=>	$args->{separator}
    };
    bless $self, $class;
}

sub validateFileType {
	my ($self, $file, $allowzip) = @_;
	
	my @allowed = (
		'image/jpeg',
		'image/tiff',
		'image/png',
		'image/x-png',
		'image/gif',
	);

	if ($allowzip) 
	{
		push(@allowed, 'application/zip');
	}
	my $ft = File::Type->new();
	
	return (grep $_ eq $ft->mime_type($file), @allowed);
}

sub isZip {
	my ($self, $file) = @_;
	
	my $ft = File::Type->new();
	
	return ($ft->mime_type($file) eq 'application/zip');
}

sub saveImageThumbnailTileZip {
	my ($self, $imageDirectory, $zipFile) = @_;

	#sets the module to open the zip file
	my $zip = Archive::Zip->new($zipFile);

	my @allimages;

	#loops through all of the zip files
	foreach my $member ($zip->members)
	{
		my $ft = File::Type->new();
		
		my $imageFile = $self->{directory}.$self->{separator}.$member->fileName;
		
		$member->extractToFileNamed($imageFile);	

		if ($self->validateFileType($imageFile, 0)){
			push(@allimages, $self->saveImageThumbnailTile($imageDirectory, $imageFile));
		}	
		
		unlink($imageFile);
	}
	
	return @allimages;
}


sub saveImageThumbnailTile {
	my ($self, $imageDirectory, $imageFile) = @_;
	
	my $filename = $self->generateRandomFileName();
	my $fileseperator = $self->{separator};

	my $imagePath = $imageDirectory.$fileseperator.$filename;
	
	mkdir($imagePath, 0775);
	
    my $origimg = Image::Magick->new;
    $origimg->Read($imageFile);
    $origimg->AutoOrient();
    $origimg->Write($imagePath.'-original.jpg');
    my $width   = $origimg->Get('width');
    my $height   = $origimg->Get('height');
    system($self->{convert}.' '.$imagePath.'-original.jpg -resize "800x800>" -quality 60 '.$imagePath.'/img-web.jpg');
    system($self->{convert}.' '.$imagePath.'-original.jpg -resize "300x300>" -quality 60 '.$imagePath.'/img-mobile.jpg');
    my $geom;
	if ($width > $height) {
		$geom = 'x80';
	}
	else {
		$geom = '80x';
	}
	$origimg->Thumbnail(geometry => $geom);
  	$origimg->Crop(geometry => '80x80', gravity => 'Center'); 
  	#create the thumbnail image
	$origimg->Write($imagePath."/thumb.jpg");
	
	undef $origimg;
	
    my $tile_dir = $imagePath;
    $tile_dir =~ s/\.\w+$//;

    # Load the source image and a little information
    my $img = Image::Magick->new;
    $img->Read($imagePath.'-original.jpg');
    my $w   = $img->Get('width');
    my $h   = $img->Get('height');

    # (Re)create the target directory
    my $ubak = umask(0);
    mkpath($tile_dir, 0, 0755);
    umask($ubak);
    # Find the next largest multiple of 256 and the power of 2
    my $dim = ($w > $h ? $w : $h);
    my $pow = -1;
    for (;;) {
       $pow++;
       my $i = 256 * (2 ** $pow);
       next if ($i < $dim);
       $dim = $i;
       last;
    }
    # Resize the source image up to the larger size, so the zoomed-out images
    # get as little of the black padding/background as possible.  Hopefully it
    # won't distort the images too badly.
    if ($dim > $w && $dim > $h) {
     # Determine the optimal pixel radius for sharpening, and do so
		my $sharp = ($w / $dim > $h / $dim
        	? $dim / $w
            : $dim / $h
         ) / 2;
        $img->Sharpen(radius => $sharp);
        # Resize
        $img->Resize(geometry => "${dim}x$dim");
    }
    # Build a new square image with a black background, and composite the
    # source image on top of it.
	my $master = Image::Magick->new;
    $master->Set('size' => "${dim}x$dim");
    $master->Read("xc:black");
    $master->Composite(
    	'image'   => $img,
        'gravity' => 'Center',
    );
    # Cleanup
    undef $img;
    # Create slice layers
    my $layer = 0;
	for (;;) {
    	# Google Maps only allows 19 layers (though I doubt we'll ever
        # reach this point).  This script limits it to 5 layers because once the 6th layer is hit 
        # it
        last if ($layer >= 5);

		my $width = 256 * (2 ** $layer);
        last if ($width > $dim);

		mkdir("$tile_dir/$layer", 0775) unless (-d "$tile_dir/$layer");

		my $crop_master = $master->Clone();
        $crop_master->Blur(radius => ($dim / $width) / 2);
        $crop_master->Resize(
        	geometry => "${width}x$width",
            blur     => .7,
		);
        my $max_loop = int($width / 256) - 1;

		foreach my $x (0 .. $max_loop) {
        	foreach my $y (0 .. $max_loop) {
            	my $crop = $crop_master->Clone();
                $crop->Crop(
                	height => 256,
                    width  => 256,
                    x      => $x * 256,
                    y      => $y * 256,
                 );
                 $crop->Write(
                 	filename => "$tile_dir/$layer/$x-$y.jpg",
                    quality  => 75,
                 );
                 $ubak = umask(0);
                 chmod 0644, "$tile_dir/$layer/$x-$y.jpg";
                 umask($ubak);
                 undef $crop;
				}
            }
		$layer++;
        # Cleanup
            undef $crop_master;
        }
   		# Cleanup
        undef $master;
		
		return $filename;
}

sub checkFileExists {
	my ($self, $imageDirectory, $imageFile) = @_;
	#if there is no directory, create one

	unless(-d $imageDirectory){
		    make_path (
		    		$imageDirectory, 
		    		0777
		    	   ) or die;
		   	
		}

   		
   	unless(-e $imageFile){
		   die "No temp!!!!";
		}
}


sub generateRandomFileName {
	my ($self) = @_;
	
	my @chars=('a'..'z','A'..'Z');
	my $randfile;
	foreach (1..20) 
	{
		# rand @chars will generate a random 
		# number between 0 and scalar @chars
		$randfile.=$chars[rand @chars];
	}
	
	return $randfile;
}

sub thumbnailImage {
	my ($self, $imagePath, $newImage) = @_;
	
	#@$self = ();
	my $img = Image::Magick->new;
	$img->Read($imagePath);
	my ($width, $height) = $img->Get('width', 'height');
	my $geom;
	if ($width > $height) {
		$geom = 'x80';
	}
	else {
		$geom = '80x';
	}
	$img->Thumbnail(geometry => $geom);
  	$img->Crop(geometry => '80x80', gravity => 'Center'); 

  	#create the thumbnail image
  	$img->Write($newImage);
	
} 

sub deleteImages {
	my ($self, @imagePaths) = @_;

	foreach (@imagePaths) {
		remove(\1,$_);
	}
}

1;
