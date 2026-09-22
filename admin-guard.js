(() => {
  const ready=localStorage.getItem('sshstore_admin_initialized')==='true';
  if(!ready && !location.pathname.endsWith('admin-setup.html')) location.replace('admin-setup.html');
})();
