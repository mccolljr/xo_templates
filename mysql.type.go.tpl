{{- $short := (shortname .Name "err" "res" "sqlstr" "db" "XOLog") -}}
{{- $table := (schema .Schema .Table.TableName) -}}
{{- $pk_name := .PrimaryKey.Name -}}
{{- if .Comment -}}
// {{ .Comment }}
{{- else -}}
// {{ .Name }} represents a row from '{{ $table }}'.
{{- end }}
type {{ .Name }} struct {
{{- range .Fields }}
	{{ .Name }} {{ retype .Type }} `db:"{{ .Col.ColumnName }}"` // {{ .Col.ColumnName }}
{{- end }}
{{- if .PrimaryKey }}

	// xo fields
	_exists, _deleted bool
{{ end }}
}

/* DISABLED 
{{ if .PrimaryKey }}
// Exists determines if the {{ .Name }} exists in the database.
func ({{ $short }} *{{ .Name }}) Exists() bool {
	return {{ $short }}._exists
}

// Deleted provides information if the {{ .Name }} has been deleted from the database.
func ({{ $short }} *{{ .Name }}) Deleted() bool {
	return {{ $short }}._deleted
}

// Insert inserts the {{ .Name }} to the database.
func ({{ $short }} *{{ .Name }}) Insert(db dbr.SessionRunner) error {
	var err error

	// if already exist, bail
	if {{ $short }}._exists {
		return errors.New("insert failed: already exists")
	}

{{ if .Table.ManualPk  }}
	_, err := db.InsertInto("{{ $table }}").
				Columns({{ colnamesstring .Fields }}).
				Record({{ $short }}).Exec()

	if err != nil {
		return err
	}
	
	{{ $short }}._exists = true
{{ else }}
	res, err := db.InsertInto("{{ $table }}").
				Columns({{ colnamesstring .Fields $pk_name}}).
				Record({{ $short }}).Exec()

	if err != nil {
		return err
	}


	// retrieve id
	id, err := res.LastInsertId()
	if err != nil {
		return err
	}

	// set primary key and existence
	{{ $short }}.{{ $pk_name }} = {{ .PrimaryKey.Type }}(id)
	{{ $short }}._exists = true
{{ end }}

	return nil
}

// Update updates the {{ .Name }} in the database.
func ({{ $short }} *{{ .Name }}) Update(db dbr.SessionRunner) error {
	var err error

	// if doesn't exist, bail
	if !{{ $short }}._exists {
		return errors.New("update failed: does not exist")
	}

	// if deleted, bail
	if {{ $short }}._deleted {
		return errors.New("update failed: marked for deletion")
	}

	_, err = db.Update("{{ $table }}").
				{{ range $field := .Fields -}}
					{{ if not (eq $field.Name $pk_name) }}
					Set("{{ colname $field.Col }}", {{ $short }}.{{ $field.Name }}).
					{{ end }}
				{{ end }}
				Exec()
	
	return err
}

// Save saves the {{ .Name }} to the database.
func ({{ $short }} *{{ .Name }}) Save(db dbr.SessionRunner) error {
	if {{ $short }}.Exists() {
		return {{ $short }}.Update(db)
	}

	return {{ $short }}.Insert(db)
}

// Delete deletes the {{ .Name }} from the database.
func ({{ $short }} *{{ .Name }}) Delete(db dbr.SessionRunner) error {
	var err error

	// if doesn't exist, bail
	if !{{ $short }}._exists {
		return nil
	}

	// if deleted, bail
	if {{ $short }}._deleted {
		return nil
	}

	_, err = db.DeleteFrom("{{ $table }}").Where("{{ colname .PrimaryKey.Col }} = ?", {{ $short }}.{{ $pk_name }}).Exec()

	if err != nil {
		return err
	}

	// set deleted
	{{ $short }}._deleted = true

	return nil
}
{{- end }}
*/
