function save_untouch_nii_gzip( nii, filename )
%SAVE_UNTOUCH_NII_GZIP Save NIFTI or ANALYZE dataset that is loaded by "load_untouch_nii.m"
% or "load_untouch_nii_gzip.m".
%  The output image format and file extension will be the same as the
%  input one (NIFTI.nii, NIFTI.img, ANALYZE.img) with an additional gzip compression for .nii files. 
% Therefore, any file extension that you specified will be ignored.
%
%  Usage: save_untouch_nii_gzip(nii, filename)
%  
%  nii - nii structure that is loaded by "load_untouch_nii.m" or "load_untouch_nii_gzip.m"
%
%  filename  - 	NIFTI file name.
%
%  - Jimmy Shen (jimmy@rotman-baycrest.on.ca)
%  - gzip: Wolf-Dieter Vogl
%

   if ~exist('nii','var') | isempty(nii) | ~isfield(nii,'hdr') | ...
	~isfield(nii,'img') | ~exist('filename','var') | isempty(filename)

      error('Usage: save_untouch_nii(nii, filename)');
   end

   if ~isfield(nii,'untouch') | nii.untouch == 0
      error('Usage: please use ''save_nii.m'' for the modified structure.');
   end

   if isfield(nii.hdr.hist,'magic') & strcmp(nii.hdr.hist.magic(1:3),'ni1')
      filetype = 1;
   elseif isfield(nii.hdr.hist,'magic') & strcmp(nii.hdr.hist.magic(1:3),'n+1')
      filetype = 2;
   else
      filetype = 0;
   end

   [p,f,ext] = fileparts(filename);
   
   if (strcmpi(ext,'.gz')==1)
       %Last extension is gz, remove .nii.gz too
       [p,f] = fileparts(fullfile(p,f));
   end
   fileprefix = fullfile(p, f);

   save_untouch_nii(nii, fileprefix);
   if (filetype == 2)
    gzip ([fileprefix '.nii']);
    delete ([fileprefix '.nii']);
   end
end

