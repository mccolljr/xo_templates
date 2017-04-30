{{- $short := (shortname .Type.Name "err" "sqlstr" "db" "q" "res" "XOLog" .Fields) -}}
{{- $table := (schema .Schema .Type.Table.TableName) -}}
// {{ .FuncName }} retrieves a row from '{{ $table }}' as a {{ .Type.Name }}.
//
// Generated from index '{{ .Index.IndexName }}'.
func {{ .FuncName }}(db dbr.SessionRunner{{ goparamlist .Fields true true }}) ({{ if not .Index.IsUnique }}[]{{ end }}*{{ .Type.Name }}, error) {
	var err error

{{- if .Index.IsUnique }}
	{{ $short }} := &{{ .Type.Name }}{
	{{- if .Type.PrimaryKey }}
		_exists: true,
	{{ end -}}
	}
{{- else }}
	{{ $short }} := []*{{ .Type.Name }}{}
{{ end }}

	_, err = db.Select({{ colnamesstring .Type.Fields }}).From("{{ $table }}").
			Where("{{ colnamesquery .Fields " AND " }}"{{ goparamlist .Fields true false}}).
			Load({{$short}})
	if err != nil {
		return nil, err
	}

	return {{ $short }}, nil

}

