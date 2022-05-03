SELECT
    gl.set_of_books_id,
    gl.name,
    gl.short_name,
    hou.name              operatin_unit,
    hou.organization_id   operating_unit_id,
    org.organization_name warehouse_name,
    org.organization_id   warehouse_id
FROM
    org_organization_definitions org,
    hr_operating_units           hou,
    gl_sets_of_books             gl
WHERE
        org.operating_unit = hou.organization_id
    AND hou.set_of_books_id = gl.set_of_books_id
ORDER BY
    1,
    3,
    6
