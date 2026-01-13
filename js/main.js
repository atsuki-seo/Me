function showToast(message) {
    event.preventDefault();

    const toast = document.getElementById("toast");
    toast.textContent = message;
    toast.className = "show";

    setTimeout(function(){
        toast.className = toast.className.replace("show", "");
    }, 3000);
}
