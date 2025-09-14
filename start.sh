sudo dnf update -y && sudo dnf upgrade --refresh -y && flatpak update -y
sudo dnf install fish neovim tmux alacritty git -y

curl -fsS https://dl.brave.com/install.sh | sh

sudo dnf install watchman cmake make g++ clang openjdk-21-jdk -y
sudo dnf install gcc gcc-c++ gdb lldb valgrind -y

sudo dnf install nasm yasm fasm -y
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

sudo dnf install gcc-gfortran gcc-objc gcc-objc++ -y
sudo dnf install boost-devel eigen3-devel -y

sudo dnf install python3 python3-pip python3-devel python3-setuptools -y
sudo dnf install python3-numpy python3-scipy python3-matplotlib -y

sudo dnf install opencv opencv-devel opencv-python3 -y
sudo dnf install opencv-contrib opencv-contrib-devel -y

sudo dnf install SDL2-devel SFML-devel allegro5-devel -y
sudo dnf install mesa-libGL-devel mesa-libGLU-devel freeglut-devel -y
sudo dnf install vulkan-devel vulkan-tools vulkan-validation-layers -y

sudo dnf install alsa-lib-devel pulseaudio-libs-devel -y
sudo dnf install ffmpeg-devel gstreamer1-devel -y

sudo dnf install openssl-devel libcurl-devel -y

sudo dnf install sqlite-devel postgresql-devel mysql-devel -y

sudo dnf install zlib-devel bzip2-devel xz-devel -y
sudo dnf install pcre-devel libxml2-devel libxslt-devel -y

sudo dnf install nodejs npm yarn -y
sudo dnf install ruby ruby-devel rubygems -y
sudo dnf install perl perl-devel perl-CPAN -y
sudo dnf install php php-devel php-composer-installer -y
sudo dnf install lua lua-devel luarocks -y
sudo dnf install R R-devel -y
sudo dnf install julia -y
sudo dnf install kotlin kotlinc -y
sudo dnf install scala scala-compiler -y
sudo dnf install erlang elixir -y
sudo dnf install ghc cabal-install stack -y
sudo dnf install ocaml ocaml-compiler-libs -y
sudo dnf install fpc lazarus -y
sudo dnf install mono-devel monodevelop -y
sudo dnf install dart -y
sudo dnf install zig -y
sudo dnf install nim -y
sudo dnf install crystal -y
sudo dnf install vala vala-devel -y
sudo dnf install tcl tcl-devel tk tk-devel -y
sudo dnf install scheme48 mit-scheme -y
sudo dnf install sbcl clisp -y
sudo dnf install prolog swi-prolog -y
sudo dnf install fortran gfortran -y

sudo dnf install opencv-core opencv-imgproc opencv-imgcodecs -y
sudo dnf install opencv-videoio opencv-highgui opencv-features2d -y
sudo dnf install opencv-calib3d opencv-objdetect opencv-dnn -y
sudo dnf install opencv-ml opencv-photo opencv-stitching -y
sudo dnf install opencv-superres opencv-videostab -y
sudo dnf install opencv4-devel opencv4-contrib -y
sudo dnf install vtk-devel pcl-devel -y
sudo dnf install itk-devel insight-toolkit -y
sudo dnf install gdal-devel geos-devel proj-devel -y
sudo dnf install dlib-devel -y
sudo dnf install tesseract-devel leptonica-devel -y
sudo dnf install eigen3-devel armadillo-devel -y
sudo dnf install gsl-devel lapack-devel blas-devel -y

sudo dnf install cairo-devel pango-devel gtk3-devel gtk4-devel -y
sudo dnf install qt5-qtbase-devel qt6-qtbase-devel -y
sudo dnf install wxGTK-devel fltk-devel -y
sudo dnf install libX11-devel libXext-devel libXrender-devel -y
sudo dnf install wayland-devel wayland-protocols-devel -y
sudo dnf install libdrm-devel libgbm-devel -y
sudo dnf install glfw-devel glew-devel -y
sudo dnf install assimp-devel bullet-devel -y
sudo dnf install freetype-devel harfbuzz-devel -y
sudo dnf install libpng-devel libjpeg-turbo-devel libtiff-devel -y
sudo dnf install libwebp-devel giflib-devel -y
sudo dnf install ImageMagick-devel GraphicsMagick-devel -y

sudo dnf install jack-audio-connection-kit-devel -y
sudo dnf install portaudio-devel libsndfile-devel -y
sudo dnf install lame-devel libvorbis-devel libtheora-devel -y
sudo dnf install x264-devel x265-devel libvpx-devel -y
sudo dnf install opus-devel speex-devel flac-devel -y

sudo dnf install godot love allegro-devel -y
sudo dnf install chipmunk-devel box2d-devel -y
sudo dnf install openal-soft-devel -y

sudo dnf install nginx httpd -y
sudo dnf install redis memcached -y
sudo dnf install elasticsearch kibana -y

sudo dnf install podman docker-compose buildah skopeo -y
sudo dnf install qemu-kvm libvirt virt-manager -y

sudo dnf install octave octave-devel maxima -y
sudo dnf install gnuplot plotutils -y
sudo dnf install hdf5-devel netcdf-devel -y
sudo dnf install fftw3-devel -y

sudo dnf install openmpi-devel mpich-devel -y
sudo dnf install openmp-devel tbb-devel -y
sudo dnf install cuda-devel opencl-devel -y

sudo dnf install subversion mercurial bazaar -y
sudo dnf install git-lfs git-annex -y

sudo dnf install texlive-scheme-full pandoc -y
sudo dnf install doxygen graphviz -y
sudo dnf install sphinx python3-sphinx -y

sudo dnf install strace ltrace perf -y
sudo dnf install systemtap systemtap-devel -y
sudo dnf install kcachegrind qcachegrind -y
