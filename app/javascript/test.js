console.log("Included");
document.querySelector("#addtag").style.color = "blue"
document.querySelector("#addtag").addEventListener("click" , (e) => {
    e.preventDefault();
    console.log("Add clicked");
    skillSet = document.querySelector("#skillSet");
    temp = document.querySelector('#new_skills_form').cloneNode(true);
    temp.style.display = "block";
    skillSet.append(temp);
})
