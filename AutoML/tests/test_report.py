import unittest
from pathlib import Path

import pandas as pd
from sklearn.linear_model import LogisticRegression

from data_processing import PowerfulDataProcessor
from model_training import UltraCompleteTrainer
from report_generator import PDFReportGenerator
from tests.test_support import AutoMLTestSupport


class TestReport(unittest.TestCase, AutoMLTestSupport):
    def setUp(self):
        self.tmpdir, self.dataframe, self.csv_path = self.prepare_csv()
        self.addCleanup(self.tmpdir.cleanup)

    def test_report_generation(self):
        processor = PowerfulDataProcessor(target_column="target", problem_type="auto")
        X_processed, y_processed, problem_type = processor.process(data=pd.read_csv(self.csv_path))

        trainer = UltraCompleteTrainer(problem_type)
        trainer.n_folds = 3
        trainer.get_all_models = lambda: {
            "LogisticRegression": LogisticRegression(max_iter=300, random_state=42)
        }
        results, _ = trainer.train_models(X_processed, y_processed, optimize_top_n=0)

        with self.temporary_cwd(self.tmpdir.name):
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
