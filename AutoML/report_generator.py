from datetime import datetime
import os

import pandas as pd

try:
    from reportlab.lib import colors
    from reportlab.lib.pagesizes import A4
    from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
    from reportlab.lib.units import inch
    from reportlab.platypus import Paragraph, SimpleDocTemplate, Spacer, Table, TableStyle
    REPORTLAB_AVAILABLE = True
except ModuleNotFoundError:
    colors = None
    A4 = None
    ParagraphStyle = None
    getSampleStyleSheet = None
    inch = None
    Paragraph = None
    SimpleDocTemplate = None
    Spacer = None
    Table = None
    TableStyle = None
    REPORTLAB_AVAILABLE = False


class PDFReportGenerator:
    @staticmethod
    def _safe_text(value, default="N/A"):
        if value is None:
            return default
        try:
            text = str(value)
            return text if text else default
        except Exception:
            return default

    @staticmethod
    def _metric_value(metrics):
        if not isinstance(metrics, dict):
            return None
        for key in ("f1", "accuracy", "r2", "rmse", "mae", "score"):
            value = metrics.get(key)
            if isinstance(value, (int, float)) and pd.notna(value):
                return float(value)
        return None

    @staticmethod
    def generate_report(results, trainer, problem_type, data_info=None):
        if not REPORTLAB_AVAILABLE:
            return PDFReportGenerator.generate_txt_report(results, trainer, problem_type, data_info)

        os.makedirs("reports", exist_ok=True)
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"reports/relatorio_automl_{timestamp}.pdf"

        try:
            doc = SimpleDocTemplate(
                filename,
                pagesize=A4,
                rightMargin=36,
                leftMargin=36,
                topMargin=36,
                bottomMargin=36,
            )

            styles = getSampleStyleSheet()
            styles.add(ParagraphStyle(
                name="TitleCustom",
                parent=styles["Title"],
                fontSize=20,
                leading=24,
                textColor=colors.HexColor("#1E88E5"),
                alignment=1,
                spaceAfter=12,
            ))
            styles.add(ParagraphStyle(
                name="SectionCustom",
                parent=styles["Heading2"],
                fontSize=13,
                leading=16,
                textColor=colors.HexColor("#0D47A1"),
                spaceBefore=8,
                spaceAfter=6,
            ))

            story = []
            story.append(Paragraph("Relatorio AutoML", styles["TitleCustom"]))
            story.append(Paragraph(f"Gerado em {datetime.now().strftime('%d/%m/%Y %H:%M')}", styles["Normal"]))
            story.append(Spacer(1, 12))

            story.append(Paragraph("Resumo Executivo", styles["SectionCustom"]))
            story.append(Paragraph(
                f"Problema: {PDFReportGenerator._safe_text(problem_type).upper()}",
                styles["BodyText"],
            ))
            story.append(Paragraph(
                f"Total de modelos: {len(results)}",
                styles["BodyText"],
            ))

            if data_info:
                story.append(Paragraph("Informacoes do Dataset", styles["SectionCustom"]))
                dataset_rows = [
                    ["Dataset", PDFReportGenerator._safe_text(data_info.get("dataset_name"))],
                    ["Amostras", PDFReportGenerator._safe_text(data_info.get("n_samples"))],
                    ["Features", PDFReportGenerator._safe_text(data_info.get("n_features"))],
                ]
                table = Table(dataset_rows, colWidths=[1.6 * inch, 4.7 * inch])
                table.setStyle(TableStyle([
                    ("BACKGROUND", (0, 0), (-1, 0), colors.whitesmoke),
                    ("TEXTCOLOR", (0, 0), (-1, -1), colors.black),
                    ("GRID", (0, 0), (-1, -1), 0.5, colors.grey),
                    ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
                    ("FONTNAME", (0, 0), (-1, -1), "Helvetica"),
                ]))
                story.append(table)
                story.append(Spacer(1, 10))

            best_name = getattr(trainer, "best_model_name", None)
            if best_name and best_name in results:
                metrics = results[best_name]
                score = PDFReportGenerator._metric_value(metrics)
                story.append(Paragraph("Melhor Modelo", styles["SectionCustom"]))
                story.append(Paragraph(f"Modelo: {PDFReportGenerator._safe_text(best_name)}", styles["BodyText"]))
                if score is not None:
                    story.append(Paragraph(f"Score principal: {score:.4f}", styles["BodyText"]))

            story.append(Paragraph("Ranking", styles["SectionCustom"]))
            ranking = trainer.get_ranking() if hasattr(trainer, "get_ranking") else pd.DataFrame()
            if isinstance(ranking, pd.DataFrame) and not ranking.empty:
                ranking_view = ranking.copy()
                if "Métrica Principal" in ranking_view.columns:
                    ranking_view["Métrica Principal"] = ranking_view["Métrica Principal"].map(
                        lambda x: f"{float(x):.4f}" if isinstance(x, (int, float)) and pd.notna(x) else PDFReportGenerator._safe_text(x)
                    )
                if "Detalhes" in ranking_view.columns:
                    ranking_view["Detalhes"] = ranking_view["Detalhes"].map(lambda x: PDFReportGenerator._safe_text(x))
                rows = [list(ranking_view.columns)] + ranking_view.head(10).values.tolist()
                table = Table(rows, repeatRows=1)
                table.setStyle(TableStyle([
                    ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#DCEBFA")),
                    ("TEXTCOLOR", (0, 0), (-1, 0), colors.black),
                    ("GRID", (0, 0), (-1, -1), 0.5, colors.grey),
                    ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
                    ("FONTNAME", (0, 1), (-1, -1), "Helvetica"),
                    ("FONTSIZE", (0, 0), (-1, -1), 8),
                ]))
                story.append(table)
            else:
                for model_name, metrics in list(results.items())[:10]:
                    story.append(Paragraph(
                        f"{PDFReportGenerator._safe_text(model_name)}: {PDFReportGenerator._safe_text(metrics)}",
                        styles["BodyText"],
                    ))

            story.append(Spacer(1, 12))
            story.append(Paragraph(
                "Recomendacao: priorize o melhor modelo, monitore performance e mantenha re-treinamento periodico.",
                styles["BodyText"],
            ))

            doc.build(story)
            return filename
        except Exception:
            return PDFReportGenerator.generate_txt_report(results, trainer, problem_type, data_info)

    @staticmethod
    def generate_txt_report(results, trainer, problem_type, data_info=None):
        os.makedirs("reports", exist_ok=True)
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"reports/relatorio_automl_{timestamp}.txt"

        with open(filename, "w", encoding="utf-8") as f:
            f.write("RELATORIO AUTOML\n")
            f.write(f"Gerado em: {datetime.now().strftime('%d/%m/%Y %H:%M')}\n")
            f.write(f"Tipo de problema: {str(problem_type).upper()}\n")
            f.write(f"Total de modelos: {len(results)}\n\n")

            if data_info:
                f.write("Informacoes do dataset:\n")
                for key, value in data_info.items():
                    f.write(f"- {key}: {value}\n")
                f.write("\n")

            best_name = getattr(trainer, "best_model_name", None)
            if best_name:
                f.write(f"Melhor modelo: {best_name}\n\n")

            f.write("Ranking resumido:\n")
            ranking = trainer.get_ranking() if hasattr(trainer, "get_ranking") else pd.DataFrame()
            if isinstance(ranking, pd.DataFrame) and not ranking.empty:
                f.write(ranking.to_string(index=False))
            else:
                for model_name, metrics in results.items():
                    f.write(f"- {model_name}: {metrics}\n")

        return filename
