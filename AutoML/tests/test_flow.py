import os
import tempfile
import unittest
from contextlib import contextmanager
from pathlib import Path

import pandas as pd
from sklearn.datasets import make_classification
from sklearn.linear_model import LogisticRegression

from data_processing import PowerfulDataProcessor
from model_training import UltraCompleteTrainer
from report_generator import PDFReportGenerator


class AutoMLFlowTest(unittest.TestCase):
    @contextmanager
    def _temporary_cwd(self, path):
        original_cwd = os.getcwd()
        os.chdir(path)
        try:
            yield
        finally:
            os.chdir(original_cwd)

    def setUp(self):
        X, y = make_classification(
            n_samples=80,
            n_features=6,
            n_informative=4,
            n_redundant=0,
            n_clusters_per_class=1,
            random_state=42,
        )
        df = pd.DataFrame(X, columns=[f"feature_{i}" for i in range(X.shape[1])])
        df["target"] = pd.Series(y).map({0: "negativo", 1: "positivo"})

        self.tmpdir = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmpdir.cleanup)

        self.csv_path = Path(self.tmpdir.name) / "dataset.csv"
        df.to_csv(self.csv_path, index=False)
        self.dataframe = df

    def test_upload_and_processing(self):
        processor = PowerfulDataProcessor(target_column="target", problem_type="auto")
        X_processed, y_processed, problem_type = processor.process(data=pd.read_csv(self.csv_path))

        self.assertEqual(problem_type, "classification")
        self.assertEqual(len(X_processed), len(y_processed))
        self.assertGreaterEqual(X_processed.shape[1], 1)

    def test_training_and_ranking(self):
        processor = PowerfulDataProcessor(target_column="target", problem_type="auto")
        X_processed, y_processed, problem_type = processor.process(data=pd.read_csv(self.csv_path))

        trainer = UltraCompleteTrainer(problem_type)
        trainer.n_folds = 3
        trainer.get_all_models = lambda: {
            "LogisticRegression": LogisticRegression(max_iter=300, random_state=42)
        }

        results, best_model_name = trainer.train_models(X_processed, y_processed, optimize_top_n=0)

        self.assertIn(best_model_name, results)
        ranking = trainer.get_ranking()
        self.assertFalse(ranking.empty)
        self.assertIn("Modelo", ranking.columns)

    def test_report_generation(self):
        processor = PowerfulDataProcessor(target_column="target", problem_type="auto")
        X_processed, y_processed, problem_type = processor.process(data=pd.read_csv(self.csv_path))

        trainer = UltraCompleteTrainer(problem_type)
        trainer.n_folds = 3
        trainer.get_all_models = lambda: {
            "LogisticRegression": LogisticRegression(max_iter=300, random_state=42)
        }
        results, _ = trainer.train_models(X_processed, y_processed, optimize_top_n=0)

        with self._temporary_cwd(self.tmpdir.name):
            report_path = Path(
                PDFReportGenerator.generate_report(
                    results,
                    trainer,
                    problem_type,
                    {
                        "dataset_name": "dataset.csv",
                        "n_samples": len(self.dataframe),
                        "n_features": self.dataframe.shape[1] - 1,
                    },
                )
            ).resolve()

        self.assertTrue(report_path.exists())
        self.assertTrue(report_path.suffix in {".pdf", ".txt"})


if __name__ == "__main__":
    unittest.main()
