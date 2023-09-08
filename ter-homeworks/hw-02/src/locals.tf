locals {
    # vm_web_name= "${ var.env }–${ var.project }"
    vm_web_name = "${ var.prefix }-web"
    vm_db_name = "${ var.prefix }-db"
}
