import '../common/json_reader.dart';

/// Размер сетки `spatial`: `{rows, cols}`.
final class GridSize {
  const GridSize({required this.rows, required this.cols});

  factory GridSize.read(JsonObj o) =>
      GridSize(rows: o.integer('rows'), cols: o.integer('cols'));

  final int rows;
  final int cols;

  Map<String, Object> toJson() => {'rows': rows, 'cols': cols};
}

/// Клетка сетки (с нуля): ответ `spatial`.
final class CellPosition {
  const CellPosition({required this.row, required this.col});

  factory CellPosition.read(JsonObj o) =>
      CellPosition(row: o.integer('row'), col: o.integer('col'));

  final int row;
  final int col;

  Map<String, Object> toJson() => {'row': row, 'col': col};
}

/// Объект на сетке: что и где показывается в фазе запоминания.
final class SpatialObject {
  const SpatialObject({
    required this.label,
    required this.row,
    required this.col,
  });

  factory SpatialObject.read(JsonObj o) => SpatialObject(
    label: o.text('label'),
    row: o.integer('row'),
    col: o.integer('col'),
  );

  final String label;
  final int row;
  final int col;

  Map<String, Object> toJson() => {'label': label, 'row': row, 'col': col};
}
