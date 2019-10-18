// Mecha paint gun. Used to set base and decal colours and to strip off decals. Also includes an unlimited supply of nanotrasen logos.
/obj/item/mecha_paint_gun
    name = "exosuit paint gun"
    desc = "An automated gun-shaped device used to apply or strip off paint and other decals, compatible with most standard exosuit models."
    icon = 'icons/obj/device.dmi'
    icon_state = "floor_painter"

    var/install_sound = 'sound/items/deconstruct.ogg'
    var/spray_sound = 'sound/effects/spray2.ogg'

    w_class = WEIGHT_CLASS_SMALL
    slot_flags = SLOT_BELT

    // Decal kits must be installed in the exosuit paint gun prior to use.
    var/list/obj/item/mecha_decal/available_decal_kits
    var/list/obj/item/compound_mecha_decal/available_compound_kits

    var/emagged = FALSE    // Emagged paint guns can apply an unlimited number of syndicate logos to compatible mechs.
    var/obj/mecha/current_mecha

/obj/item/mecha_paint_gun/Initialize()
    available_decal_kits = list(new/obj/item/mecha_decal/nanotrasen_logo)
    available_compound_kits = list()

/obj/item/mecha_paint_gun/attack_obj(obj/O, mob/user)
    if(istype(O, /obj/mecha))
        openUI(O, user)
    else
        . = ..()

/obj/item/mecha_paint_gun/attackby(obj/O, mob/user)
    if(istype(O, /obj/item/mecha_decal))
        install_kit(O)
        user.drop_item()
        O.loc = null
    else if(istype(O, /obj/item/compound_mecha_decal))
        install_compound_kit(O)
        user.drop_item()
        O.loc = null
    else
        . = ..()

/obj/item/mecha_paint_gun/proc/install_kit(var/obj/item/mecha_decal/D)
    if(!(locate(D.type) in available_decal_kits))
        available_decal_kits.Add(D)
        to_chat(usr, "<span class='notice'>You slot [D] into [src].</span>")
        playsound(loc, install_sound, 50, 1)
    else
        to_chat(usr, "<span class='warning'>[src] already has this pattern installed!</span>")

/obj/item/mecha_paint_gun/proc/install_compound_kit(var/obj/item/compound_mecha_decal/D)
    available_compound_kits.Add(D)
    to_chat(usr, "<span class='notice'>You slot [D] into [src].</span>")
    playsound(loc, install_sound, 50, 1)

/obj/item/mecha_paint_gun/proc/UI_colour_box(var/colour)
    return "<span style='font-face: fixedsys; background-color: [colour]; color: [colour]'>___</span>"

/obj/item/mecha_paint_gun/proc/openUI(obj/O, mob/user)
    current_mecha = O
    if(current_mecha.occupant)
        to_chat(user, "<span class='warning'>The exosuit must be unoccupied before you can paint it!</span>")
        return
    if(!current_mecha.basecoat_icon)
        to_chat(user, "<span class='warning'>[src] is not compatible with this exosuit!</span>")
        return
    var/dat
    user.set_machine(src)
    if(!current_mecha)
        dat += "<b>No exosuit selected.</b><br/>"
    else
        dat += "<div class='paintGun'>"
        dat += "<b>Base Coat:</b> <A href='?src=[UID()];choice=set_base'>Colour</A>[UI_colour_box(current_mecha.basecoat_colour)] <A href='?src=[UID()];choice=default_base'>Default</A><br/>"
        dat += "<b>Glow:</b> <A href='?src=[UID()];choice=set_glow'>Colour</A>[UI_colour_box(current_mecha.glow_colour)] <A href='?src=[UID()];choice=default_glow'>Default</A><br/><br/>"
        if(current_mecha.decals.len != 0)
            dat += "<b>Decals Applied to [current_mecha.name]:</b><br/>"
            for(var/obj/item/mecha_decal/decal in current_mecha.decals)
                if(decal.mutable_colour)
                    dat += "[decal.decal_name]: <A href='?src=[UID()];decalcolour=\ref[decal]'>Colour</A>[UI_colour_box(decal.decal_colour)] <A href='?src=[UID()];decalstrip=\ref[decal]'>Strip</A><br/>"
                else
                    dat += "[decal.decal_name]: <A href='?src=[UID()];decalstrip=\ref[decal]'>Strip</A><br/>"
            dat += "<br/>"

        dat += "<b>Installed Decals:</b><br/>"
        for(var/obj/item/mecha_decal/D in available_decal_kits)
            if(!(current_mecha.type in D.compatible_mecha))
                dat += "<s>[D.decal_name]</s>: Incompatible with [current_mecha.name]<br/>"
            else if(locate(D.type) in current_mecha.decals)
                dat += "<s>[D.decal_name]</s>: Already applied to [current_mecha.name]!<br/>"
            else if(D.mutable_colour)
                dat += "<A href='?src=[UID()];decalapply=\ref[D]'>[D.decal_name]</A> <A href='?src=[UID()];innerdecalcolour=\ref[D]'>Colour</A>[UI_colour_box(D.decal_colour)]<br/>"
            else
                dat += "<A href='?src=[UID()];decalapply=\ref[D]'>[D.decal_name]</A><br/>"
        if(available_compound_kits.len > 0)
            for(var/obj/item/compound_mecha_decal/D in available_compound_kits)
                if(!(current_mecha.type in D.compatible_mecha))
                    dat += "<s>[D.decal_name]</s>: Incompatible with [current_mecha.name]<br/>"
                else
                    var/found_nonapplied_decal = FALSE
                    for(var/obj/item/mecha_decal/MD in D.decals)
                        if(!(locate(D.type) in current_mecha.decals)) 
                            found_nonapplied_decal = TRUE
                    if(found_nonapplied_decal)
                        dat += "<A href='?src=[UID()];compounddecalapply=\ref[D]'>[D.decal_name]</A> "
                        for(var/obj/item/mecha_decal/MD in D.decals)
                            if(MD.mutable_colour)
                                dat += "<A href='?src=[UID()];innerdecalcolour=\ref[MD]'>Colour</A>[UI_colour_box(MD.decal_colour)] "
                        dat += "<br/>"
                    else
                        dat += "<s>[D.decal_name]</s>: All component decals already applied to [current_mecha.name].<br/>"
        dat += "<br/><A href='?src=[UID()];choice=defaultdecals'>Return All To Default</A><br/><br/>"

    var/datum/browser/popup = new(user, "mechapaintgun", "<u>Exosuit Paint Gun:</u> [current_mecha]", 400, 350)
    popup.set_content(dat)
    popup.open()
    return

/obj/item/mecha_paint_gun/emag_act()
    emagged = TRUE
    available_decal_kits.Add(new/obj/item/mecha_decal/syndicate_logo)
    visible_message("[src] sparks briefly.")

/obj/item/mecha_paint_gun/Topic(href, href_list, user)
    if(..())
        return 1
    if(!current_mecha.Adjacent(usr))
        return
    if(href_list["choice"])
        switch(href_list["choice"])
            if("set_base")
                current_mecha.basecoat_colour = input("Select the new base colour:", "Base Colour", current_mecha.basecoat_colour) as color|null
                if(current_mecha.Adjacent(usr))
                    to_chat(usr, "<span class='notice'>You carefully cover the exosuit in a new coat of paint.</span>")
                    playsound(loc, spray_sound, 50, 1, -6)
                    openUI(current_mecha, usr)
            if("set_glow")
                if(current_mecha.Adjacent(usr))
                    current_mecha.glow_colour = input("Select the new glow colour:", "Glow Colour", current_mecha.glow_colour) as color|null
                    to_chat(usr, "<span class='notice'>You carefully cover the exosuit in a new coat of paint.</span>")
                    playsound(loc, spray_sound, 50, 1, -6)
                    openUI(current_mecha, usr)
            if("default_base")
                if(current_mecha.Adjacent(usr))
                    current_mecha.basecoat_colour = initial(current_mecha.basecoat_colour)
                    to_chat(usr, "<span class='notice'>You carefully cover the exosuit in a new coat of paint.</span>")
                    playsound(loc, spray_sound, 50, 1, -6)
                    openUI(current_mecha, usr)
            if("default_glow")
                if(current_mecha.Adjacent(usr))
                    current_mecha.glow_colour = initial(current_mecha.glow_colour)
                    to_chat(usr, "<span class='notice'>You carefully cover the exosuit in a new coat of paint.</span>")
                    playsound(loc, spray_sound, 50, 1, -6)
                    openUI(current_mecha, usr)
            if("defaultdecals")
                if(current_mecha.Adjacent(usr))
                    current_mecha.decals = list(current_mecha.default_decals)
                    current_mecha.basecoat_colour = initial(current_mecha.basecoat_colour)
                    current_mecha.glow_colour = initial(current_mecha.glow_colour)
                    to_chat(usr, "<span class='notice'>You strip all the decals off [current_mecha] and return it to its original colour scheme.</span>")
                    playsound(loc, spray_sound, 50, 1, -6)
                    openUI(current_mecha, usr)
    
    if(href_list["decalcolour"])
        if(current_mecha.Adjacent(usr))
            var/hrefstring = href_list["decalcolour"]
            var/obj/item/mecha_decal/D = locate(hrefstring)
            D.decal_colour = input("Select the new decal colour:", "Decal Colour", D.decal_colour) as color|null
            to_chat(usr, "<span class='notice'>You carefully spray over the decal, recolouring it neatly.</span>")
            playsound(loc, spray_sound, 50, 1, -6)
            openUI(current_mecha, usr)

    if(href_list["innerdecalcolour"])
        var/hrefstring = href_list["innerdecalcolour"]
        var/obj/item/mecha_decal/D = locate(hrefstring)
        D.decal_colour = input("Select the new decal colour:", "Decal Colour", D.decal_colour) as color|null
        openUI(current_mecha, usr)

    if(href_list["decalstrip"])
        if(current_mecha.Adjacent(usr))
            var/hrefstring = href_list["decalstrip"]
            var/obj/item/mecha_decal/D = locate(hrefstring)
            current_mecha.decals.Remove(D)
            qdel(D)
            to_chat(usr, "<span class='notice'>You carefully strip off the decal.</span>")
            playsound(loc, spray_sound, 50, 1, -6)
            openUI(current_mecha, usr)

    if(href_list["decalapply"])
        var/hrefstring = href_list["decalapply"]
        var/obj/item/mecha_decal/D = locate(hrefstring)
        if(current_mecha.Adjacent(usr))
            if(D.install_on_mecha(current_mecha))
                to_chat(usr, "<span class='notice'>You spray the exosuit down as tiny manipulators handle the small details.</span>")
                playsound(loc, spray_sound, 50, 1, -6)
                openUI(current_mecha, usr)

    if(href_list["compounddecalapply"])
        var/hrefstring = href_list["compounddecalapply"]
        var/obj/item/compound_mecha_decal/D = locate(hrefstring)
        if(current_mecha.Adjacent(usr))
            if(D.install_on_mecha(current_mecha))
                to_chat(usr, "<span class='notice'>You spray the exosuit down as tiny manipulators handle the small details.</span>")
                playsound(loc, spray_sound, 50, 1, -6)
                openUI(current_mecha, usr)

    current_mecha.update_icon()

// Containers for mecha decals. Each one is a physical object which is contained in a list within the mecha when added.
// Each mecha has a decal root string of the form "[mech_name]-decal" which is used to fetch and apply the decal icon.
// There is no governance as to which decals can be applied in which order.
/obj/item/mecha_decal
    name = "exosuit decal pattern"
    desc = "A small storage device containing an exosuit decal pattern. Load it into an exosuit paint gun."
    icon = 'icons/obj/module.dmi'
    icon_state = "harddisk_mini"

    var/decal_string                        // The string which is added to the mech's decal_root in order to apply the icon. 
    var/decal_name                          // The name shown by the decal UI.
    var/mutable_colour = FALSE              // Whether the colour can be set. Off for things with a set colour, like the nanotrasen logo.
    var/glowing = FALSE                     // Determines the layer the overlays are placed on. Will shine in the dark if true.
    var/decal_layer = 1                     // The higher the decal layer, the less things will cover it.
    var/decal_colour = "#000000"            // If the colour can be set, it is read from here when determining overlays.
    var/list/obj/mecha/compatible_mecha     // Which mech types the kit can be applied to.

/obj/item/mecha_decal/attack_obj(obj/O, mob/living/user)
    visible_message("Attack Obj: [O.name], Type: [O.type]")
    if(istype(O, /obj/mecha))
        install_on_mecha(O, user)
    else
        . = ..()

/obj/item/mecha_decal/proc/install_on_mecha(obj/mecha/M)
    if(M.type in compatible_mecha)
        if(M.add_decal(clone()))
            return TRUE
    else
        to_chat(usr, "<span class='warning'>[src] is not compatible with [M]!</span>")
    return FALSE

/obj/item/mecha_decal/proc/clone()          // Creates a copy of itself to be stored in the mecha being painted.
    var/obj/item/mecha_decal/copy = new()
    copy.name = name
    copy.desc = desc
    copy.icon = icon
    copy.icon_state = icon_state
    copy.decal_string = decal_string
    copy.decal_name = decal_name
    copy.mutable_colour = mutable_colour
    copy.glowing = glowing
    copy.decal_layer = decal_layer
    copy.decal_colour = decal_colour
    copy.compatible_mecha = compatible_mecha
    return copy


// For decals which add multiple layers. All decals contained within are added to the mech at once in sequential order.
/obj/item/compound_mecha_decal
    name = "exosuit complex decal pattern"
    desc = "A small storage device containing an elaborate exosuit decal pattern. Load it into an exosuit paint gun."
    icon = 'icons/obj/module.dmi'
    icon_state = "harddisk_mini"

    var/decal_name                          // The name shown by the decal UI.
    var/list/obj/item/mecha_decal/decals
    var/list/obj/mecha/compatible_mecha  

/obj/item/compound_mecha_decal/proc/install_on_mecha(obj/mecha/M)
    if(decals && (M.type in compatible_mecha))
        for(var/obj/item/mecha_decal/decal in decals)
            M.add_decal(decal.clone())
        return TRUE
    else
        to_chat(usr, "<span class='warning'>[src] is not compatible with [M]!</span>")
        return FALSE

///////////////////////
// Decal Definitions //
///////////////////////

/obj/item/mecha_decal/stripes
    name = "exosuit decal pattern (Racing Stripes)"
    decal_string = "stripes"
    decal_name = "Racing Stripes"
    mutable_colour = TRUE
    decal_colour = "#A00000"  
    compatible_mecha = list(
        /obj/mecha/working/ripley,
        /obj/mecha/working/ripley/firefighter
    )

/obj/item/mecha_decal/nanotrasen_logo
    name = "exosuit decal pattern (Nanotrasen Logo)"
    decal_string = "nt_logo"
    decal_name = "Nanotrasen Logo"
    decal_layer = 2
    mutable_colour = FALSE
    decal_colour = "#000000"  
    compatible_mecha = list(
        /obj/mecha/working/ripley,
        /obj/mecha/working/ripley/firefighter
    )

/obj/item/mecha_decal/syndicate_logo
    name = "exosuit decal pattern (Syndicate Logo)"
    decal_string = "syn_logo"
    decal_name = "Syndicate Logo"
    decal_layer = 2
    mutable_colour = FALSE
    decal_colour = "#000000"  
    compatible_mecha = list(
        /obj/mecha/working/ripley,
        /obj/mecha/working/ripley/firefighter
    )

/obj/item/mecha_decal/titan
    name = "exosuit decal pattern (Ripley Titan Skull)"
    decal_string = "titan"
    decal_name = "Titan Skull"
    mutable_colour = FALSE
    decal_layer = 3
    compatible_mecha = list(
        /obj/mecha/working/ripley,
        /obj/mecha/working/ripley/firefighter
    )

/obj/item/mecha_decal/titaneyes
    name = "exosuit decal pattern (Ripley Titan Eyes)"
    decal_string = "titaneyes"
    decal_name = "Titan Eyes"
    mutable_colour = TRUE
    glowing = TRUE
    decal_layer = 4
    decal_colour = "#00AB00"
    compatible_mecha = list(
        /obj/mecha/working/ripley,
        /obj/mecha/working/ripley/firefighter
    )

// Testing for complex decal
/obj/item/compound_mecha_decal/nanotrasen_and_stripes
    name = "exosuit complex decal pattern (NT Logo and Stripes)"
    decal_name = "NT Logo with Stripes"
    compatible_mecha = list(
        /obj/mecha/working/ripley,
        /obj/mecha/working/ripley/firefighter
    )

/obj/item/compound_mecha_decal/nanotrasen_and_stripes/Initialize()
    var/obj/item/mecha_decal/S = new/obj/item/mecha_decal/stripes
    S.decal_colour = "#5e84ab"
    var/obj/item/mecha_decal/L = new/obj/item/mecha_decal/nanotrasen_logo
    L.glowing = TRUE
    decals = list(S,L)

// Replacement for titan paintkit.
/obj/item/compound_mecha_decal/titan
    name = "exosuit complex decal pattern (Titan's Fist Ripley)"
    decal_name = "Titan's Fist"
    compatible_mecha = list(
        /obj/mecha/working/ripley,
        /obj/mecha/working/ripley/firefighter
    )

/obj/item/compound_mecha_decal/titan/Initialize()
    decals = list(new/obj/item/mecha_decal/titan, new/obj/item/mecha_decal/titaneyes, new/obj/item/mecha_decal/stripes)



