*&---------------------------------------------------------------------*
*& Report zrefactor_v2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zrefactor_v2 LINE-SIZE 90.

INTERFACE output_generator DEFERRED.
CLASS product DEFINITION DEFERRED.

TYPES items_table TYPE TABLE OF REF TO product.

CLASS product DEFINITION.

  PUBLIC SECTION.
    METHODS constructor IMPORTING imc_product TYPE zproducts.

    METHODS set IMPORTING im_product TYPE zproducts.

    METHODS get RETURNING VALUE(re_product) TYPE zproducts.

  PRIVATE SECTION.
    DATA: product TYPE zproducts.

ENDCLASS.

CLASS product IMPLEMENTATION.

  METHOD constructor.
    me->set( imc_product ).
  ENDMETHOD.

  METHOD set.
    me->product = im_product.
  ENDMETHOD.

  METHOD get.
    re_product = me->product.
  ENDMETHOD.
ENDCLASS.


CLASS purchase_order DEFINITION.

  PUBLIC SECTION.
    METHODS add_item IMPORTING im_item TYPE REF TO product.

    METHODS get_po_total RETURNING VALUE(re_total) TYPE zproducts-unit_price.

    METHODS get_items EXPORTING items_list TYPE items_table.

    METHODS link_display_generator IMPORTING generator_obj TYPE REF TO output_generator.

  PRIVATE SECTION.
    DATA items_list TYPE items_table.
    DATA display_generator TYPE REF TO output_generator.

ENDCLASS.

CLASS purchase_order IMPLEMENTATION.

  METHOD add_item.
    APPEND im_item TO items_list.
  ENDMETHOD.

  METHOD get_po_total.
    DATA: r_product  TYPE REF TO product,
          wa_product TYPE zproducts,
          vg_total   TYPE zproducts-unit_price.

    LOOP AT items_list INTO r_product.
      wa_product = r_product->get( ).
      vg_total = wa_product-unit_price * wa_product-quantity.
      ADD vg_total TO re_total.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_items.
    items_list = me->items_list.
  ENDMETHOD.

  METHOD link_display_generator.
    me->display_generator = generator_obj.
  ENDMETHOD.

ENDCLASS.

INTERFACE output_generator.
  METHODS generate IMPORTING po_object TYPE REF TO purchase_order.
ENDINTERFACE.

CLASS report_list DEFINITION.

  PUBLIC SECTION.
    INTERFACES output_generator.

ENDCLASS.

CLASS report_list IMPLEMENTATION.
  METHOD output_generator~generate.
    DATA: r_product  TYPE REF TO product,
          wa_product TYPE zproducts,
          vg_total   TYPE zproducts-unit_price,
          vg_total_p TYPE zproducts-unit_price.

    DATA items_list TYPE items_table.

    po_object->get_items( IMPORTING items_list = items_list ).

    LOOP AT items_list INTO r_product.
      AT FIRST.
        FORMAT COLOR COL_HEADING.
        WRITE:  /1 'ID',
                5 'Description',
                30 'Quant.',
                60 'Unit Price',
                80 'Total'.
        FORMAT COLOR OFF.
        ULINE.
      ENDAT.

      wa_product = r_product->get( ).
      vg_total = wa_product-unit_price * wa_product-quantity.

      WRITE: /1  wa_product-id,
              5  wa_product-description,
              30 wa_product-quantity,
              60 wa_product-unit_price,
              80 vg_total.

      ADD vg_total TO vg_total_p.

      AT LAST.
        ULINE.
        FORMAT COLOR 7.
        WRITE: / 'Total of Purchase Order --> ', vg_total_p.
      ENDAT.

    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

DATA: r_product  TYPE REF TO product,
      r_pur_ord  TYPE REF TO purchase_order,
      wa_product TYPE zproducts.

START-OF-SELECTION.

  CREATE OBJECT r_pur_ord.

  wa_product-id = '025'.
  wa_product-description = 'Cellphone 3000'.
  wa_product-quantity = 3.
  wa_product-unit_price = 1400.

  CREATE OBJECT r_product
    EXPORTING
      imc_product = wa_product.
  r_pur_ord->add_item( r_product ).

  wa_product-id = '984'.
  wa_product-description = 'TV 40pol'.
  wa_product-quantity = 6.
  wa_product-unit_price = 3400.

  CREATE OBJECT r_product
    EXPORTING
      imc_product = wa_product.
  r_pur_ord->add_item( r_product ).

  wa_product-id = '758'.
  wa_product-description = 'Audio System 439'.
  wa_product-quantity = 2.
  wa_product-unit_price = 7800.

  CREATE OBJECT r_product
    EXPORTING
      imc_product = wa_product.
  r_pur_ord->add_item( r_product ).

  DATA out_display TYPE REF TO output_generator.
  out_display = NEW report_list( ) .
  out_display->generate( r_pur_ord ).
