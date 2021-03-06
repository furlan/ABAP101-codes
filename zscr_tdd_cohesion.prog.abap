*&---------------------------------------------------------------------*
*& Report zscr_tdd_cohesion
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zscr_tdd_cohesion.

CLASS employee DEFINITION DEFERRED.

INTERFACE calculator.
  METHODS calculate IMPORTING employee     TYPE REF TO employee
                    RETURNING VALUE(value) TYPE zcalc_result.
ENDINTERFACE.


CLASS employee DEFINITION.

  PUBLIC SECTION.
    METHODS constructor IMPORTING employee_name     TYPE string
                                  employee_salary   TYPE zcalc_result
                                  employee_position TYPE string.
    METHODS get_salary RETURNING VALUE(salary) TYPE zcalc_result.
    METHODS get_position RETURNING VALUE(position) TYPE string.

  PRIVATE SECTION.
    DATA name TYPE string.
    DATA salary TYPE zcalc_result.
    DATA position TYPE string.

ENDCLASS.

CLASS employee IMPLEMENTATION.

  METHOD constructor.
    me->name = employee_name.
    me->position = employee_position.
    me->salary = employee_salary.
  ENDMETHOD.

  METHOD get_salary.
    salary = me->salary.
  ENDMETHOD.

  METHOD get_position.
    position = me->position.
  ENDMETHOD.

ENDCLASS.

CLASS developer_calculator DEFINITION.
  PUBLIC SECTION.
    INTERFACES calculator.
ENDCLASS.

CLASS developer_calculator IMPLEMENTATION.
  METHOD calculator~calculate.
    IF employee->get_salary( ) > '3000'.
      value = employee->get_salary( ) * '0.8'.
    ELSE.
      value = employee->get_salary( ) * '0.9'.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS dba_calculator DEFINITION.
  PUBLIC SECTION.
    INTERFACES calculator.
ENDCLASS.

CLASS dba_calculator IMPLEMENTATION.
  METHOD calculator~calculate.
    IF employee->get_salary( ) > '2500'.
      value = employee->get_salary( ) * '0.75'.
    ELSE.
      value = employee->get_salary( ) * '0.85'.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS tester_calculator DEFINITION.
  PUBLIC SECTION.
    INTERFACES calculator.
ENDCLASS.

CLASS tester_calculator IMPLEMENTATION.
  METHOD calculator~calculate.
    IF employee->get_salary( ) > '2500'.
      value = employee->get_salary( ) * '0.75'.
    ELSE.
      value = employee->get_salary( ) * '0.85'.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS payment_calculator DEFINITION.
  PUBLIC SECTION.
    METHODS calculate_payment IMPORTING employee     TYPE REF TO employee
                              RETURNING VALUE(value) TYPE zcalc_result.
ENDCLASS.

CLASS payment_calculator IMPLEMENTATION.
  METHOD calculate_payment.
    DATA calculator TYPE REF TO calculator.
    DATA(calculator_name) = employee->get_position( ) && '_calculator'.
    TRANSLATE calculator_name TO UPPER CASE.
    CREATE OBJECT calculator TYPE (calculator_name).
    value = calculator->calculate( employee ).
  ENDMETHOD.

ENDCLASS.

CLASS test_payment_calculator DEFINITION FOR TESTING RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA test_employee TYPE REF TO employee.
    DATA test_payment_calculator TYPE REF TO payment_calculator.
    METHODS setup.
    METHODS calc_developer_bellow_limit FOR TESTING.
    METHODS calc_developer_above_limit FOR TESTING.
    METHODS calc_dba_bellow_limit FOR TESTING.
    METHODS calc_dba_above_limit FOR TESTING.
    METHODS calc_tester_bellow_limit FOR TESTING.
    METHODS calc_tester_above_limit FOR TESTING.
ENDCLASS.

CLASS test_payment_calculator IMPLEMENTATION.
  METHOD setup.
    CREATE OBJECT me->test_payment_calculator.
  ENDMETHOD.

  METHOD calc_developer_bellow_limit.
    CREATE OBJECT me->test_employee
      EXPORTING
        employee_name     = 'Chaves'
        employee_position = 'Developer'
        employee_salary   = '1500.00'.

    DATA(value) = me->test_payment_calculator->calculate_payment( me->test_employee ).

    cl_abap_unit_assert=>assert_equals( exp = '1350.00' act = value ).
  ENDMETHOD.

  METHOD calc_developer_above_limit.
    CREATE OBJECT me->test_employee
      EXPORTING
        employee_name     = 'Chaves'
        employee_position = 'Developer'
        employee_salary   = '4000.00'.

    DATA(value) = me->test_payment_calculator->calculate_payment( me->test_employee ).

    cl_abap_unit_assert=>assert_equals( exp = '3200.00' act = value ).
  ENDMETHOD.

  METHOD calc_dba_bellow_limit.
    CREATE OBJECT me->test_employee
      EXPORTING
        employee_name     = 'Chaves'
        employee_position = 'DBA'
        employee_salary   = '500.00'.

    DATA(value) = me->test_payment_calculator->calculate_payment( me->test_employee ).

    cl_abap_unit_assert=>assert_equals( exp = '425.00' act = value ).
  ENDMETHOD.

  METHOD calc_dba_above_limit.
    CREATE OBJECT me->test_employee
      EXPORTING
        employee_name     = 'Chaves'
        employee_position = 'DBA'
        employee_salary   = '3500.00'.

    DATA(value) = me->test_payment_calculator->calculate_payment( me->test_employee ).

    cl_abap_unit_assert=>assert_equals( exp = '2625.00' act = value ).
  ENDMETHOD.

  METHOD calc_tester_bellow_limit.
    CREATE OBJECT me->test_employee
      EXPORTING
        employee_name     = 'Chaves'
        employee_position = 'Tester'
        employee_salary   = '500.00'.

    DATA(value) = me->test_payment_calculator->calculate_payment( me->test_employee ).

    cl_abap_unit_assert=>assert_equals( exp = '425.00' act = value ).
  ENDMETHOD.

  METHOD calc_tester_above_limit.
    CREATE OBJECT me->test_employee
      EXPORTING
        employee_name     = 'Chaves'
        employee_position = 'Tester'
        employee_salary   = '3500.00'.

    DATA(value) = me->test_payment_calculator->calculate_payment( me->test_employee ).

    cl_abap_unit_assert=>assert_equals( exp = '2625.00' act = value ).
  ENDMETHOD.
ENDCLASS.




















* eof
